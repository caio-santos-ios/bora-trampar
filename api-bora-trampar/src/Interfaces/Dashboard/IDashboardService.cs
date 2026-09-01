using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Responses.Dashboard;

namespace api_bora_trampar.src.Interfaces.Dashboard
{
    public interface IDashboardService
    {
        Task<ResponseApi<DashboardResponse>> GetMetricsAsync(DateTime? startDate, DateTime? endDate);
    }
}
