using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Utils;
using MongoDB.Bson;

namespace api_bora_trampar.src.Services
{
    public class UserService(IUserRepository repository) : IUserService
    {
        #region READ
        public async Task<ResponseApi<List<dynamic>>> GetAllAsync()
        {
            try
            {
                List<BsonDocument> pipeline =
                [
                    new("$match", new BsonDocument
                    {
                        {"deleted", false},
                    }),
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", new BsonDocument("$toString", "$_id")},
                        {"name", 1},
                        {"email", 1},
                        {"whatsapp", 1},
                        {"role", 1},
                        {"photo", new BsonDocument("$ifNull", new BsonArray { "$photo", "" })},
                        {"active", new BsonDocument("$ifNull", new BsonArray { "$active", true })},
                        {"walletBalance", new BsonDocument("$ifNull", new BsonArray { "$wallet_balance", 0m })},
                        {"wallet_balance", new BsonDocument("$ifNull", new BsonArray { "$wallet_balance", 0m })},
                        {"createdAt", 1}
                    }),
                    new("$sort", new BsonDocument { { "createdAt", -1 } } )
                ];

                List<dynamic> users = await repository.GetAllAsync(pipeline);

                return new(users, 200, "Usuários listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<User?>> GetByIdAsync(string id)
        {
            try
            {
                User? user = await repository.GetByIdAsync(id);
                if (user is null) return new(null, 404, "Usuário não encontrado");

                return new(user, 200, "Usuário buscado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
        #region CREATE
        #endregion
        #region UPDATE
        public async Task<ResponseApi<User?>> UpdateAsync(UpdateUserRequest request)
        {
            try
            {
                User entity = ObjectMapper.Map<UpdateUserRequest, User>(request);

                entity.UpdatedAt = DateTime.Now;
                User? user = await repository.UpdateAsync(entity);
                if (user is null) return new(null, 400, "Falha ao atualzar usuário");

                return new(user, 200, "Usuário atualizado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
        #region DELETE
        public async Task<ResponseApi<User?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                User? existedUser = await repository.GetByIdAsync(request.Id);
                if (existedUser is null) return new(null, 404, "Usuário não encontrado");

                existedUser.Deleted = true;
                existedUser.DeletedAt = DateTime.Now;

                User user = await repository.DeleteAsync(existedUser);
                if (user is null) return new(null, 400, "Falha ao excluir usuário");

                return new(user, 204, "Usuário excluido com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        public async Task<ResponseApi<decimal>> UpdateWalletBalanceAsync(string userId, decimal amountDelta)
        {
            try
            {
                User? user = await repository.GetByIdAsync(userId);
                if (user is null) return new(0, 404, "Usuário não encontrado");

                user.WalletBalance = Math.Max(0, user.WalletBalance + amountDelta);
                user.UpdatedAt = DateTime.UtcNow;

                await repository.UpdateAsync(user);
                return new(user.WalletBalance, 200, "Saldo atualizado com sucesso");
            }
            catch (Exception ex)
            {
                return new(0, 500, $"Erro ao atualizar saldo: {ex.Message}");
            }
        }
    }
}