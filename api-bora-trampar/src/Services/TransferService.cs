using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models._Base;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests._Base;
using api_bora_trampar.src.Requests.Asaas;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Utils;
using MongoDB.Bson;
using MongoDB.Driver;

namespace api_bora_trampar.src.Services
{
    public class TransferService(ITransferRepository repository, AppDbContext appDbContext, IAsaasService asaasService) : ITransferService
    {
        #region READ
        public async Task<ResponseApi<PaginationApi<List<dynamic>>>> GetAllAsync(GetAllRequest request)
        {
            try
            {
                Pagination<Transfer> pagination = new(request.QueryParams);

                List<BsonDocument> countPipeline =
                [
                    new("$match", pagination.PipelineFilter)
                ];

                List<BsonDocument> pipeline =
                [
                    new("$match", pagination.PipelineFilter),
                    new("$sort", pagination.PipelineSort),
                    new("$skip", pagination.Skip),
                    new("$limit", pagination.Limit),
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", new BsonDocument("$toString", "$_id")},
                        {"userId", "$user_id"},
                        {"amount", 1},
                        {"pixKeyType", "$pix_key_type"},
                        {"pixKey", "$pix_key"},
                        {"status", 1},
                        {"notes", 1},
                        {"createdAt", "$created_at"}
                    })
                ];

                long count = await repository.GetCountAsync(countPipeline);
                List<dynamic> transfers = await repository.GetAllAsync(pipeline);

                PaginationApi<List<dynamic>> data = new(transfers, count, pagination.PageNumber, pagination.PageSize);

                return new(data, 200, "Transferências listadas com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<List<dynamic>>> GetByUserAsync(string userId)
        {
            try
            {
                List<BsonDocument> pipeline =
                [
                    new("$match", new BsonDocument { { "user_id", userId }, { "deleted", false } }),
                    new("$sort", new BsonDocument { { "created_at", -1 } }),
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", new BsonDocument("$toString", "$_id")},
                        {"userId", "$user_id"},
                        {"amount", new BsonDocument("$toDouble", "$amount")},
                        {"pixKeyType", "$pix_key_type"},
                        {"pixKey", "$pix_key"},
                        {"status", 1},
                        {"notes", 1},
                        {"createdAt", "$created_at"}
                    })
                ];

                List<dynamic> transfers = await repository.GetAllAsync(pipeline);

                return new(transfers, 200, "Histórico de transferências listado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Transfer?>> GetByIdAsync(string id)
        {
            try
            {
                Transfer? transfer = await repository.GetByIdAsync(id);
                if (transfer is null) return new(null, 404, "Transferência não encontrada");

                return new(transfer, 200, "Transferência buscada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region CREATE
        public async Task<ResponseApi<Transfer?>> CreateAsync(CreateTransferRequest request)
        {
            try
            {
                var user = await appDbContext.Users.Find(u => u.Id == request.UserId && !u.Deleted).FirstOrDefaultAsync();
                if (user is null) return new(null, 404, "Usuário não encontrado");

                if (user.WalletBalance < request.Amount)
                {
                    return new(null, 400, "Saldo insuficiente para realizar esta transferência");
                }

                ResponseApi<dynamic?> response = await asaasService.CreatePixTransferAsync(new()
                {
                    Description = "Retirada do valor",
                    PixAddressKey = request.PixKey,
                    PixAddressKeyType = request.PixKeyType,
                    Value = request.Amount
                });

                if (response.Data is null) return new(null, 400, $"Falha ao solicitar transferência - {response.Message}");



                var proProfile = await appDbContext.ProfileProfessionals
                    .Find(p => p.UserId == request.UserId && !p.Deleted)
                    .FirstOrDefaultAsync();

                if (proProfile != null)
                {
                    await appDbContext.ProfileProfessionals.UpdateOneAsync(
                        p => p.Id == proProfile.Id,
                        Builders<ProfileProfessional>.Update
                            .Set(p => p.PixKeyType, request.PixKeyType)
                            .Set(p => p.PixKey, request.PixKey)
                    );
                }

                Transfer entity = ObjectMapper.Map<CreateTransferRequest, Transfer>(request);
                entity.Status = "PENDING";
                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;
                entity.AsaasId = response.Data.transferId;

                Transfer? transfer = await repository.CreateAsync(entity);
                if (transfer is null) return new(null, 400, "Falha ao solicitar transferência");



                return new(transfer, 201, "Transferência solicitada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region UPDATE
        public async Task<ResponseApi<Transfer?>> UpdateAsync(UpdateTransferRequest request)
        {
            try
            {
                Transfer? existed = await repository.GetByIdAsync(request.Id);
                if (existed is null) return new(null, 404, "Transferência não encontrada");

                if (!string.IsNullOrWhiteSpace(request.Status))
                {
                    existed.Status = request.Status;
                }
                if (!string.IsNullOrWhiteSpace(request.Notes))
                {
                    existed.Notes = request.Notes;
                }

                existed.UpdatedAt = DateTime.UtcNow;
                Transfer? transfer = await repository.UpdateAsync(existed);
                if (transfer is null) return new(null, 400, "Falha ao atualizar transferência");

                return new(transfer, 200, "Transferência atualizada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        public async Task<ResponseApi<Transfer?>> CheckTransferAsync(CheckTransferRequest request)
        {
            try
            {
                Transfer? existed = await repository.GetByAsaasIdAsync(request.Transfer.Id);
                if (existed is null) return new(null, 404, "Transferência não encontrada");

                existed.Status = request.Transfer.Status;
                existed.UpdatedAt = DateTime.UtcNow;
                existed.Proof = request.Transfer.TransactionReceiptUrl;
                Transfer? transfer = await repository.UpdateAsync(existed);
                if (transfer is null) return new(null, 400, "Falha ao atualizar transferência");

                User? user = await appDbContext.Users.Find(u => u.Id == existed.UserId && !u.Deleted).FirstOrDefaultAsync();
                if (user is null) return new(null, 404, "Usuário não encontrado");

                decimal newBalance = user.WalletBalance - existed.Amount;
                await appDbContext.Users.UpdateOneAsync(
                    u => u.Id == existed.UserId,
                    Builders<User>.Update.Set(u => u.WalletBalance, newBalance)
                );

                return new(null, 200, "Transferência atualizada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region DELETE
        public async Task<ResponseApi<Transfer?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                Transfer? existed = await repository.GetByIdAsync(request.Id);
                if (existed is null) return new(null, 404, "Transferência não encontrada");

                existed.Deleted = true;
                existed.DeletedAt = DateTime.UtcNow;

                Transfer transfer = await repository.DeleteAsync(existed);
                return new(transfer, 204, "Transferência excluída com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
    }
}
