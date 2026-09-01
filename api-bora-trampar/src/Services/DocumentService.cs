using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Utils;
using MongoDB.Bson;

namespace api_bora_trampar.src.Services
{
    public class DocumentService(IDocumentRepository repository) : IDocumentService
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
                        {"number", 1},
                        {"uri_file", 1},
                        {"createdAt", 1}
                    }),
                    new("$sort", new BsonDocument { { "createdAt", -1 } } )
                ];

                List<dynamic> documents = await repository.GetAllAsync(pipeline);

                return new(documents, 200, "Documentos listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Document?>> GetByIdAsync(string id)
        {
            try
            {
                Document? document = await repository.GetByIdAsync(id);
                if (document is null) return new(null, 404, "Documento não encontrado");

                return new(document, 200, "Documento buscado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region CREATE
        public async Task<ResponseApi<Document?>> CreateAsync(CreateDocumentRequest request)
        {
            try
            {
                Document entity = ObjectMapper.Map<CreateDocumentRequest, Document>(request);

                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;
                Document? document = await repository.CreateAsync(entity);
                if (document is null) return new(null, 400, "Falha ao criar documento");

                return new(document, 201, "Documento criado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region UPDATE
        public async Task<ResponseApi<Document?>> UpdateAsync(UpdateDocumentRequest request)
        {
            try
            {
                Document entity = ObjectMapper.Map<UpdateDocumentRequest, Document>(request);

                entity.UpdatedAt = DateTime.UtcNow;
                Document? document = await repository.UpdateAsync(entity);
                if (document is null) return new(null, 400, "Falha ao atualizar documento");

                return new(document, 200, "Documento atualizado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region DELETE
        public async Task<ResponseApi<Document?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                Document? existedDocument = await repository.GetByIdAsync(request.Id);
                if (existedDocument is null) return new(null, 404, "Documento não encontrado");

                existedDocument.Deleted = true;
                existedDocument.DeletedAt = DateTime.UtcNow;
                existedDocument.DeletedBy = request.DeletedBy;

                Document document = await repository.DeleteAsync(existedDocument);
                if (document is null) return new(null, 400, "Falha ao excluir documento");

                return new(document, 204, "Documento excluído com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
    }
}
