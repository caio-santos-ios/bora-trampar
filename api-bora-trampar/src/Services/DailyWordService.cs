using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models._Base;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests._Base;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Utils;
using MongoDB.Bson;

namespace api_bora_trampar.src.Services
{
    public class DailyWordService(IDailyWordRepository repository) : IDailyWordService
    {
        #region READ
        public async Task<ResponseApi<PaginationApi<List<dynamic>>>> GetAllAsync(GetAllRequest request)
        {
            try
            {
                Pagination<DailyWord> pagination = new(request.QueryParams);

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
                        {"title", 1},
                        {"verse", 1},
                        {"reference", 1},
                        {"message", 1},
                        {"target_audience", 1},
                        {"targetAudience", "$target_audience"},
                        {"is_active", 1},
                        {"isActive", "$is_active"},
                        {"start_date", 1},
                        {"startDate", "$start_date"},
                        {"end_date", 1},
                        {"endDate", "$end_date"},
                        {"created_at", 1},
                        {"createdAt", "$created_at"}
                    })
                ];

                long count = await repository.GetCountAsync(countPipeline);
                List<dynamic> dailyWords = await repository.GetAllAsync(pipeline);

                PaginationApi<List<dynamic>> data = new(dailyWords, count, pagination.PageNumber, pagination.PageSize);

                return new(data, 200, "Palavras do dia listadas com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<DailyWord?>> GetByIdAsync(string id)
        {
            try
            {
                DailyWord? dailyWord = await repository.GetByIdAsync(id);
                if (dailyWord is null) return new(null, 404, "Palavra do dia não encontrada");

                return new(dailyWord, 200, "Palavra do dia buscada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<DailyWord?>> GetTodayAsync(string audience)
        {
            try
            {
                DailyWord? dailyWord = await repository.GetTodayAsync(audience);
                if (dailyWord is null) return new(null, 200, "Nenhuma palavra do dia ativa encontrada para o momento");
                System.Console.WriteLine(dailyWord.Title);
                System.Console.WriteLine(dailyWord.Message);

                return new(dailyWord, 200, "Palavra do dia de hoje obtida com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region CREATE
        public async Task<ResponseApi<DailyWord?>> CreateAsync(CreateDailyWordRequest request)
        {
            try
            {
                DailyWord entity = ObjectMapper.Map<CreateDailyWordRequest, DailyWord>(request);

                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;
                DailyWord? dailyWord = await repository.CreateAsync(entity);
                if (dailyWord is null) return new(null, 400, "Falha ao criar palavra do dia");

                return new(dailyWord, 201, "Palavra do dia criada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region UPDATE
        public async Task<ResponseApi<DailyWord?>> UpdateAsync(UpdateDailyWordRequest request)
        {
            try
            {
                DailyWord? existed = await repository.GetByIdAsync(request.Id);
                if (existed is null) return new(null, 404, "Palavra do dia não encontrada");

                existed.Title = request.Title ?? existed.Title;
                existed.Verse = request.Verse ?? existed.Verse;
                existed.Reference = request.Reference ?? existed.Reference;
                existed.Message = request.Message ?? existed.Message;
                existed.TargetAudience = request.TargetAudience ?? existed.TargetAudience;
                existed.IsActive = request.IsActive;
                existed.StartDate = request.StartDate;
                existed.EndDate = request.EndDate;
                existed.UpdatedAt = DateTime.UtcNow;
                existed.UpdatedBy = request.UpdatedBy;

                DailyWord? dailyWord = await repository.UpdateAsync(existed);
                if (dailyWord is null) return new(null, 400, "Falha ao atualizar palavra do dia");

                return new(dailyWord, 200, "Palavra do dia atualizada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region DELETE
        public async Task<ResponseApi<DailyWord?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                DailyWord? existed = await repository.GetByIdAsync(request.Id);
                if (existed is null) return new(null, 404, "Palavra do dia não encontrada");

                existed.Deleted = true;
                existed.DeletedAt = DateTime.UtcNow;
                existed.DeletedBy = request.DeletedBy;

                DailyWord dailyWord = await repository.DeleteAsync(existed);
                if (dailyWord is null) return new(null, 400, "Falha ao excluir palavra do dia");

                return new(dailyWord, 204, "Palavra do dia excluída com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
    }
}
