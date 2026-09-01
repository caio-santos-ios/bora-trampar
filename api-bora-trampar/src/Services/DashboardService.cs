using api_bora_trampar.src.Interfaces.Dashboard;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Responses.Dashboard;

namespace api_bora_trampar.src.Services
{
    public class DashboardService(IDashboardRepository repository) : IDashboardService
    {
        public async Task<ResponseApi<DashboardResponse>> GetMetricsAsync(DateTime? startDate, DateTime? endDate)
        {
            try
            {
                var data = await repository.GetMetricsAsync(startDate, endDate);
                return new ResponseApi<DashboardResponse>(data, 200, "Métricas do dashboard obtidas com sucesso");
            }
            catch (Exception ex)
            {
                return new ResponseApi<DashboardResponse>(null, 500, $"Erro ao processar métricas do dashboard: {ex.Message}");
            }
        }
    }
}
