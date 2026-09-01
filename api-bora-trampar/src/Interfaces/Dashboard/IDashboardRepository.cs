using api_bora_trampar.src.Responses.Dashboard;

namespace api_bora_trampar.src.Interfaces.Dashboard
{
    public interface IDashboardRepository
    {
        Task<DashboardResponse> GetMetricsAsync(DateTime? startDate, DateTime? endDate);
    }
}
