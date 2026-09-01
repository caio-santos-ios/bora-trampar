using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Utils;
using MongoDB.Bson;

namespace api_bora_trampar.src.Services
{
    public class CategoryService(ICategoryRepository repository) : ICategoryService
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
                        {"description", 1},
                        {"icon", 1},
                        {"createdAt", 1}
                    }),
                    new("$sort", new BsonDocument { { "createdAt", -1 } } )
                ];

                List<dynamic> categories = await repository.GetAllAsync(pipeline);

                return new(categories, 200, "Categorias listadas com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        public async Task<ResponseApi<Category?>> GetByIdAsync(string id)
        {
            try
            {
                Category? category = await repository.GetByIdAsync(id);
                if (category is null) return new(null, 404, "Categoria não encontrado");

                return new(category, 200, "Categoria buscado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
        #region CREATE
        public async Task<ResponseApi<Category?>> CreateAsync(CreateCategoryRequest request)
        {
           try
            {
                Category entity = ObjectMapper.Map<CreateCategoryRequest, Category>(request);

                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;
                Category? category = await repository.CreateAsync(entity);
                if (category is null) return new(null, 400, "Falha ao criar categoria");

                return new(category, 201, "Categoria criada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
        #region UPDATE
        public async Task<ResponseApi<Category?>> UpdateAsync(UpdateCategoryRequest request)
        {
            try
            {
                Category entity = ObjectMapper.Map<UpdateCategoryRequest, Category>(request);

                entity.UpdatedAt = DateTime.Now;
                Category? category = await repository.UpdateAsync(entity);
                if (category is null) return new(null, 400, "Falha ao atualzar categoria");

                return new(category, 200, "Categoria atualizado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
        #region DELETE
        public async Task<ResponseApi<Category?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                Category? existedCategory = await repository.GetByIdAsync(request.Id);
                if (existedCategory is null) return new(null, 404, "Categoria não encontrado");

                existedCategory.Deleted = true;
                existedCategory.DeletedAt = DateTime.Now;

                Category category = await repository.DeleteAsync(existedCategory);
                if (category is null) return new(null, 400, "Falha ao excluir usuário");

                return new(category, 204, "Categoria excluida com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
    }
}