using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Enums;
using api_bora_trampar.src.Interfaces.Dashboard;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Responses.Dashboard;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class DashboardRepository(AppDbContext db) : IDashboardRepository
    {
        public async Task<DashboardResponse> GetMetricsAsync(DateTime? startDate, DateTime? endDate)
        {
            var response = new DashboardResponse();

            var totalPros = await db.Users.CountDocumentsAsync(u =>
                !u.Deleted && u.Role == RoleUserEnum.Professional
            );
            response.ActivePros = (int)totalPros;

            var pendingVerifications = await db.Approvals.CountDocumentsAsync(a => !a.Deleted);
            response.PendingVerifications = (int)pendingVerifications;

            var appointments = await db.Appointments
                .Find(a => !a.Deleted)
                .SortByDescending(a => a.CreatedAt)
                .ToListAsync();

            response.MonthAppointments = appointments.Count;

            var userIds = appointments.Select(a => a.CustomerId).Concat(appointments.Select(a => a.ProfissionalId)).Where(id => !string.IsNullOrEmpty(id)).Distinct().ToList();
            var users = await db.Users.Find(u => u.Id != null && userIds.Contains(u.Id)).ToListAsync();
            var userMap = users.Where(u => u.Id != null).ToDictionary(u => u.Id!, u => u.Name);

            decimal totalRevenue = 0;
            var recent = new List<RecentAppointmentItem>();

            foreach (var a in appointments.Take(6))
            {
                var customerName = a.CustomerId != null && userMap.TryGetValue(a.CustomerId, out var cName) ? cName : "Cliente";
                var proName = a.ProfissionalId != null && userMap.TryGetValue(a.ProfissionalId, out var pName) ? pName : "Profissional";

                recent.Add(new RecentAppointmentItem
                {
                    Id = a.Id ?? "",
                    Customer = customerName,
                    Professional = proName,
                    Service = "Serviço Prestado",
                    Date = a.Date.ToString("dd/MM/yyyy") + (!string.IsNullOrEmpty(a.Hour) ? $" {a.Hour}" : ""),
                    Value = 150.0m,
                    Status = "confirmed",
                    StatusText = "Confirmado"
                });
            }

            response.RecentAppointments = recent;
            response.TotalRevenue = totalRevenue;

            var categories = await db.Categories.Find(c => !c.Deleted).ToListAsync();
            response.CategoryDistribution = categories.Select(c => new CategoryDistributionItem
            {
                Name = c.Name,
                Count = 1
            }).ToList();

            var monthNames = new[] { "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez" };
            var currentMonth = DateTime.UtcNow.Month - 1;
            for (int i = 5; i >= 0; i--)
            {
                int mIdx = (currentMonth - i + 12) % 12;
                response.RevenueHistory.Add(new RevenueHistoryItem
                {
                    Label = monthNames[mIdx],
                    Revenue = 0
                });
            }

            return response;
        }
    }
}
