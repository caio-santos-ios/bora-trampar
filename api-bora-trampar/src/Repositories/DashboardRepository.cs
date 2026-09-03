using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Enums;
using api_bora_trampar.src.Interfaces.Dashboard;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Responses.Dashboard;
using MongoDB.Bson;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class DashboardRepository(AppDbContext db) : IDashboardRepository
    {
        public async Task<DashboardResponse> GetMetricsAsync(DateTime? startDate, DateTime? endDate)
        {
            var response = new DashboardResponse();

            try
            {
                var profiles = await db.ProfileProfessionals
                    .Find(p => !p.Deleted && p.IsProfileCompleted)
                    .ToListAsync();

                foreach (var profile in profiles)
                {
                    if (string.IsNullOrWhiteSpace(profile.IdentityDocumentFrontUrl) &&
                        string.IsNullOrWhiteSpace(profile.IdentityDocumentBackUrl) &&
                        string.IsNullOrWhiteSpace(profile.IdentitySelfieUrl))
                    {
                        continue;
                    }

                    var existing = await db.Approvals
                        .Find(a => !a.Deleted && a.ProfissionalId == profile.UserId)
                        .FirstOrDefaultAsync();

                    if (existing == null)
                    {
                        var isApproved = string.Equals(profile.IdentityVerificationStatus, "Approved", StringComparison.OrdinalIgnoreCase);
                        var isRejected = string.Equals(profile.IdentityVerificationStatus, "Rejected", StringComparison.OrdinalIgnoreCase);
                        var isCorrection = string.Equals(profile.IdentityVerificationStatus, "Correction", StringComparison.OrdinalIgnoreCase);

                        var newApproval = new Approval
                        {
                            ProfissionalId = profile.UserId,
                            DocumentType = string.IsNullOrWhiteSpace(profile.IdentityDocumentType) ? "CNH" : profile.IdentityDocumentType,
                            DocumentNumber = profile.IdentityDocumentNumber,
                            RgFrontUrl = profile.IdentityDocumentFrontUrl,
                            RgBackUrl = profile.IdentityDocumentBackUrl,
                            SelfieUrl = profile.IdentitySelfieUrl,
                            Status = isApproved ? "approved" : isRejected ? "rejected" : isCorrection ? "correction" : "analysis",
                            Approved = isApproved,
                            ReviewNotes = profile.IdentityVerificationNotes ?? string.Empty,
                            CreatedAt = profile.CreatedAt,
                            UpdatedAt = profile.UpdatedAt
                        };

                        await db.Approvals.InsertOneAsync(newApproval);
                    }
                }
            }
            catch
            {
            }

            try
            {
                var pendingVerifications = await db.Approvals.CountDocumentsAsync(a =>
                    !a.Deleted && !a.Approved && a.Status != "approved" && a.Status != "rejected"
                );
                response.PendingVerifications = (int)pendingVerifications;
            }
            catch
            {
                response.PendingVerifications = 0;
            }

            try
            {
                var proRoleRegex = new BsonRegularExpression("^profi?ssional$", "i");
                var userFilter = Builders<BsonDocument>.Filter.And(
                    Builders<BsonDocument>.Filter.Ne("deleted", true),
                    Builders<BsonDocument>.Filter.Regex("role", proRoleRegex)
                );
                var usersColl = db.Users.Database.GetCollection<BsonDocument>("users");
                var totalPros = await usersColl.CountDocumentsAsync(userFilter);

                if (totalPros == 0)
                {
                    totalPros = await db.ProfileProfessionals.CountDocumentsAsync(p => !p.Deleted);
                }

                response.ActivePros = (int)totalPros;
            }
            catch
            {
                response.ActivePros = 0;
            }

            try
            {
                var appointmentsColl = db.Appointments.Database.GetCollection<BsonDocument>("appointments");
                var filter = Builders<BsonDocument>.Filter.Ne("deleted", true);
                var sort = Builders<BsonDocument>.Sort.Descending("created_at");
                var appDocs = await appointmentsColl.Find(filter).Sort(sort).ToListAsync();

                response.MonthAppointments = appDocs.Count;

                var userIds = new List<string>();
                foreach (var d in appDocs)
                {
                    if (d.Contains("customer_id") && !d["customer_id"].IsBsonNull && !string.IsNullOrWhiteSpace(d["customer_id"].AsString))
                        userIds.Add(d["customer_id"].AsString);
                    if (d.Contains("profissional_id") && !d["profissional_id"].IsBsonNull && !string.IsNullOrWhiteSpace(d["profissional_id"].AsString))
                        userIds.Add(d["profissional_id"].AsString);
                }
                userIds = userIds.Distinct().ToList();

                var users = await db.Users.Find(u => u.Id != null && userIds.Contains(u.Id)).ToListAsync();
                var userMap = users.Where(u => u.Id != null).GroupBy(u => u.Id!).ToDictionary(g => g.Key, g => g.First().Name);

                decimal totalRevenue = 0;
                var recent = new List<RecentAppointmentItem>();

                foreach (var a in appDocs)
                {
                    decimal val = 0;
                    if (a.Contains("total_price") && !a["total_price"].IsBsonNull)
                    {
                        if (a["total_price"].IsDecimal128) val = (decimal)a["total_price"].AsDecimal128;
                        else if (a["total_price"].IsDouble) val = (decimal)a["total_price"].AsDouble;
                        else if (a["total_price"].IsInt32) val = a["total_price"].AsInt32;
                        else if (a["total_price"].IsInt64) val = a["total_price"].AsInt64;
                        else if (a["total_price"].IsString && decimal.TryParse(a["total_price"].AsString, out var dVal)) val = dVal;
                    }

                    string status = a.Contains("status") && !a["status"].IsBsonNull ? a["status"].AsString : "confirmed";
                    if (status.Equals("completed", StringComparison.OrdinalIgnoreCase) || status.Equals("confirmed", StringComparison.OrdinalIgnoreCase))
                    {
                        totalRevenue += val;
                    }

                    if (recent.Count < 6)
                    {
                        var cId = a.Contains("customer_id") && !a["customer_id"].IsBsonNull ? a["customer_id"].AsString : "";
                        var pId = a.Contains("profissional_id") && !a["profissional_id"].IsBsonNull ? a["profissional_id"].AsString : "";
                        var customerName = !string.IsNullOrEmpty(cId) && userMap.TryGetValue(cId, out var cName) ? cName : "Cliente";
                        var proName = !string.IsNullOrEmpty(pId) && userMap.TryGetValue(pId, out var pName) ? pName : "Profissional";

                        string dateStr = "";
                        if (a.Contains("date") && !a["date"].IsBsonNull)
                        {
                            if (a["date"].IsValidDateTime) dateStr = a["date"].ToUniversalTime().ToString("dd/MM/yyyy");
                            else if (a["date"].IsString) dateStr = a["date"].AsString;
                        }

                        string hourStr = a.Contains("hour") && !a["hour"].IsBsonNull ? a["hour"].AsString : "";

                        recent.Add(new RecentAppointmentItem
                        {
                            Id = a.Contains("_id") ? a["_id"].ToString() ?? "" : "",
                            Customer = customerName,
                            Professional = proName,
                            Service = a.Contains("service_names") && !a["service_names"].IsBsonNull ? a["service_names"].AsString : "Serviço Prestado",
                            Date = dateStr + (!string.IsNullOrEmpty(hourStr) ? $" {hourStr}" : ""),
                            Value = val > 0 ? val : 150.0m,
                            Status = status,
                            StatusText = status.Equals("completed", StringComparison.OrdinalIgnoreCase) ? "Concluído" : status.Equals("cancelled", StringComparison.OrdinalIgnoreCase) ? "Cancelado" : "Confirmado"
                        });
                    }
                }

                response.RecentAppointments = recent;
                response.TotalRevenue = totalRevenue;
            }
            catch
            {
            }

            try
            {
                var categories = await db.Categories.Find(c => !c.Deleted).ToListAsync();
                response.CategoryDistribution = categories.Select(c => new CategoryDistributionItem
                {
                    Name = c.Name,
                    Count = 1
                }).ToList();
            }
            catch
            {
            }

            try
            {
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
            }
            catch
            {
            }

            return response;
        }
    }
}
