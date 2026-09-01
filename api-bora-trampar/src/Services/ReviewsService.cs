using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Utils;
using MongoDB.Bson;

namespace api_bora_trampar.src.Services
{
    public class ReviewsService(IReviewsRepository repository) : IReviewsService
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
                        {"point", 1},
                        {"notes", 1},
                        {"createdAt", 1}
                    }),
                    new("$sort", new BsonDocument { { "createdAt", -1 } } )
                ];

                List<dynamic> reviews = await repository.GetAllAsync(pipeline);

                return new(reviews, 200, "Avaliações listadas com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Reviews?>> GetByIdAsync(string id)
        {
            try
            {
                Reviews? review = await repository.GetByIdAsync(id);
                if (review is null) return new(null, 404, "Avaliação não encontrada");

                return new(review, 200, "Avaliação buscada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region CREATE
        public async Task<ResponseApi<Reviews?>> CreateAsync(CreateReviewsRequest request)
        {
            try
            {
                Reviews entity = ObjectMapper.Map<CreateReviewsRequest, Reviews>(request);

                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;
                Reviews? review = await repository.CreateAsync(entity);
                if (review is null) return new(null, 400, "Falha ao criar avaliação");

                return new(review, 201, "Avaliação criada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region UPDATE
        public async Task<ResponseApi<Reviews?>> UpdateAsync(UpdateReviewsRequest request)
        {
            try
            {
                Reviews entity = ObjectMapper.Map<UpdateReviewsRequest, Reviews>(request);

                entity.UpdatedAt = DateTime.UtcNow;
                Reviews? review = await repository.UpdateAsync(entity);
                if (review is null) return new(null, 400, "Falha ao atualizar avaliação");

                return new(review, 200, "Avaliação atualizada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region DELETE
        public async Task<ResponseApi<Reviews?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                Reviews? existedReview = await repository.GetByIdAsync(request.Id);
                if (existedReview is null) return new(null, 404, "Avaliação não encontrada");

                existedReview.Deleted = true;
                existedReview.DeletedAt = DateTime.UtcNow;
                existedReview.DeletedBy = request.DeletedBy;

                Reviews review = await repository.DeleteAsync(existedReview);
                if (review is null) return new(null, 400, "Falha ao excluir avaliação");

                return new(review, 204, "Avaliação excluída com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
    }
}
