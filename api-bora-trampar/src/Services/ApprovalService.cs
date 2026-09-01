using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Utils;
using MongoDB.Bson;

namespace api_bora_trampar.src.Services
{
    public class ApprovalService(IApprovalRepository repository) : IApprovalService
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
                        {"profissional_id", 1},
                        {"createdAt", 1}
                    }),
                    new("$sort", new BsonDocument { { "createdAt", -1 } } )
                ];

                List<dynamic> approvals = await repository.GetAllAsync(pipeline);

                return new(approvals, 200, "Aprovações listadas com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Approval?>> GetByIdAsync(string id)
        {
            try
            {
                Approval? approval = await repository.GetByIdAsync(id);
                if (approval is null) return new(null, 404, "Aprovação não encontrada");

                return new(approval, 200, "Aprovação buscada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region CREATE
        public async Task<ResponseApi<Approval?>> CreateAsync(CreateApprovalRequest request)
        {
            try
            {
                Approval entity = ObjectMapper.Map<CreateApprovalRequest, Approval>(request);

                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;
                Approval? approval = await repository.CreateAsync(entity);
                if (approval is null) return new(null, 400, "Falha ao criar aprovação");

                return new(approval, 201, "Aprovação criada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region UPDATE
        public async Task<ResponseApi<Approval?>> UpdateAsync(UpdateApprovalRequest request)
        {
            try
            {
                Approval entity = ObjectMapper.Map<UpdateApprovalRequest, Approval>(request);

                entity.UpdatedAt = DateTime.UtcNow;
                Approval? approval = await repository.UpdateAsync(entity);
                if (approval is null) return new(null, 400, "Falha ao atualizar aprovação");

                return new(approval, 200, "Aprovação atualizada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region DELETE
        public async Task<ResponseApi<Approval?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                Approval? existedApproval = await repository.GetByIdAsync(request.Id);
                if (existedApproval is null) return new(null, 404, "Aprovação não encontrada");

                existedApproval.Deleted = true;
                existedApproval.DeletedAt = DateTime.UtcNow;
                existedApproval.DeletedBy = request.DeletedBy;

                Approval approval = await repository.DeleteAsync(existedApproval);
                if (approval is null) return new(null, 400, "Falha ao excluir aprovação");

                return new(approval, 204, "Aprovação excluída com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
    }
}
