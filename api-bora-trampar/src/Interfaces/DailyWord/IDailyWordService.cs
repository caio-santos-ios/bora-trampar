using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models._Base;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests._Base;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Interfaces
{
    public interface IDailyWordService
    {
        Task<ResponseApi<PaginationApi<List<dynamic>>>> GetAllAsync(GetAllRequest request);
        Task<ResponseApi<DailyWord?>> GetByIdAsync(string id);
        Task<ResponseApi<DailyWord?>> GetTodayAsync(string audience);
        Task<ResponseApi<DailyWord?>> CreateAsync(CreateDailyWordRequest request);
        Task<ResponseApi<DailyWord?>> UpdateAsync(UpdateDailyWordRequest request);
        Task<ResponseApi<DailyWord?>> DeleteAsync(DeleteRequest request);
    }
}
