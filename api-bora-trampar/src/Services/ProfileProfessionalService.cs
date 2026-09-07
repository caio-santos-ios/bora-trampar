using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Enums;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using MongoDB.Driver;

namespace api_bora_trampar.src.Services
{
    public class ProfileProfessionalService(
        IProfileProfessionalRepository repository,
        AppDbContext appDbContext) : IProfileProfessionalService
    {
        public async Task<ResponseApi<ProfileProfessional?>> GetByUserIdAsync(string userId)
        {
            try
            {
                var profile = await repository.GetByUserIdAsync(userId);
                if (profile is null) return new(null, 404, "Perfil profissional não encontrado");

                var approval = await appDbContext.Approvals
                    .Find(a => !a.Deleted && a.ProfissionalId == userId)
                    .FirstOrDefaultAsync();

                if (approval != null)
                {
                    var status = (approval.Status ?? "").ToLower().Trim();
                    if (approval.Approved || status == "approved" || status == "approve")
                    {
                        profile.IdentityVerificationStatus = "Approved";
                    }
                    else if (status == "rejected" || status == "reject")
                    {
                        profile.IdentityVerificationStatus = "Rejected";
                    }
                    else if (status == "correction")
                    {
                        profile.IdentityVerificationStatus = "Correction";
                    }
                    if (!string.IsNullOrEmpty(approval.ReviewNotes))
                    {
                        profile.IdentityVerificationNotes = approval.ReviewNotes;
                    }
                }

                return new(profile, 200, "Perfil profissional encontrado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<ProfileProfessional?>> GetByIdAsync(string id)
        {
            try
            {
                var profile = await repository.GetByIdAsync(id);
                if (profile is null) return new(null, 404, "Perfil profissional não encontrado");

                var approval = await appDbContext.Approvals
                    .Find(a => !a.Deleted && a.ProfissionalId == profile.UserId)
                    .FirstOrDefaultAsync();

                if (approval != null)
                {
                    var status = (approval.Status ?? "").ToLower().Trim();
                    if (approval.Approved || status == "approved" || status == "approve")
                    {
                        profile.IdentityVerificationStatus = "Approved";
                    }
                    else if (status == "rejected" || status == "reject")
                    {
                        profile.IdentityVerificationStatus = "Rejected";
                    }
                    else if (status == "correction")
                    {
                        profile.IdentityVerificationStatus = "Correction";
                    }
                    if (!string.IsNullOrEmpty(approval.ReviewNotes))
                    {
                        profile.IdentityVerificationNotes = approval.ReviewNotes;
                    }
                }

                return new(profile, 200, "Perfil profissional encontrado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<List<ProfileProfessional>>> GetAllAsync()
        {
            try
            {
                var profiles = await repository.GetProfileAllAsync();

                var approvals = await appDbContext.Approvals
                    .Find(a => !a.Deleted)
                    .ToListAsync();

                var approvalMap = approvals
                    .GroupBy(a => a.ProfissionalId)
                    .ToDictionary(g => g.Key, g => g.OrderByDescending(x => x.UpdatedAt).First());

                foreach (var profile in profiles)
                {
                    if (approvalMap.TryGetValue(profile.UserId, out var approval))
                    {
                        var status = (approval.Status ?? "").ToLower().Trim();
                        if (approval.Approved || status == "approved" || status == "approve")
                        {
                            profile.IdentityVerificationStatus = "Approved";
                        }
                        else if (status == "rejected" || status == "reject")
                        {
                            profile.IdentityVerificationStatus = "Rejected";
                        }
                        else if (status == "correction")
                        {
                            profile.IdentityVerificationStatus = "Correction";
                        }
                        if (!string.IsNullOrEmpty(approval.ReviewNotes))
                        {
                            profile.IdentityVerificationNotes = approval.ReviewNotes;
                        }
                    }
                }

                return new(profiles, 200, "Perfis profissionais listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        
        public async Task<ResponseApi<List<dynamic>>> GetProfessionalAvailabilityAsync(DateTime date, string hour, double latitude, double longitude)
        {
            try
            {
                if (Math.Abs(latitude) > Math.Abs(longitude) && longitude > -30 && latitude < -30)
                {
                    (latitude, longitude) = (longitude, latitude);
                }

                bool hasCustomerLoc = Math.Abs(latitude) > 0.001 || Math.Abs(longitude) > 0.001;

                var allProfiles = await repository.GetProfileAllAsync();

                var profUserIdsFromProfiles = allProfiles
                    .Select(p => p.UserId)
                    .Where(id => !string.IsNullOrWhiteSpace(id))
                    .ToHashSet(StringComparer.OrdinalIgnoreCase);

                var allUsers = await appDbContext.Users
                    .Find(u => !u.Deleted)
                    .ToListAsync();

                var profUsers = allUsers.Where(u =>
                    u.Role == RoleUserEnum.Professional ||
                    u.Role == RoleUserEnum.Profissional ||
                    profUserIdsFromProfiles.Contains(u.Id) ||
                    (!string.IsNullOrEmpty(u.Role.ToString()) && u.Role.ToString().Contains("prof", StringComparison.OrdinalIgnoreCase))
                ).ToList();

                var profileMap = new Dictionary<string, ProfileProfessional>(StringComparer.OrdinalIgnoreCase);
                foreach (var p in allProfiles)
                {
                    if (!string.IsNullOrWhiteSpace(p.UserId))
                        profileMap[p.UserId.Trim()] = p;
                    if (!string.IsNullOrWhiteSpace(p.Id) && !profileMap.ContainsKey(p.Id.Trim()))
                        profileMap[p.Id.Trim()] = p;
                }

                var candidateUserIds = profUsers.Select(u => u.Id).ToList();
                var searchStart = date.Date.AddDays(-1);
                var searchEnd = date.Date.AddDays(2);

                var existingAppointments = await appDbContext.Appointments
                    .Find(a => !a.Deleted
                            && candidateUserIds.Contains(a.ProfissionalId)
                            && a.Date >= searchStart
                            && a.Date < searchEnd)
                    .ToListAsync();

                var canceledStatuses = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
                {
                    "cancelled", "canceled", "declined", "cancelado", "recusado"
                };

                var busyProfessionalIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                foreach (var apt in existingAppointments)
                {
                    if (string.IsNullOrEmpty(apt.ProfissionalId)) continue;
                    if (canceledStatuses.Contains(apt.Status ?? "")) continue;

                    bool isSameDay = (apt.Date.Year == date.Year && apt.Date.Month == date.Month && apt.Date.Day == date.Day)
                                  || (apt.Date.ToLocalTime().Year == date.Year && apt.Date.ToLocalTime().Month == date.Month && apt.Date.ToLocalTime().Day == date.Day);

                    if (!isSameDay) continue;

                    if (!string.IsNullOrWhiteSpace(hour))
                    {
                        if (string.Equals(apt.Hour?.Trim(), hour.Trim(), StringComparison.OrdinalIgnoreCase))
                        {
                            busyProfessionalIds.Add(apt.ProfissionalId);
                        }
                        else if (TryParseTime(apt.Hour, out var aptTime) && TryParseTime(hour, out var reqTime))
                        {
                            if (Math.Abs((aptTime - reqTime).TotalMinutes) < 60)
                            {
                                busyProfessionalIds.Add(apt.ProfissionalId);
                            }
                        }
                    }
                    else
                    {
                        busyProfessionalIds.Add(apt.ProfissionalId);
                    }
                }

                List<dynamic> usersResult = [];
                foreach (var u in profUsers)
                {
                    profileMap.TryGetValue(u.Id, out var profile);

                    if (busyProfessionalIds.Contains(u.Id) && profUsers.Count > 1)
                        continue;

                    if (profile != null && !profile.IsAvailableNow && profUsers.Count > 1)
                        continue;

                    bool isWorking = IsProfessionalWorkingAt(profile, date, hour);
                    if (!isWorking && profUsers.Count > 1)
                        continue;

                    double distKm = 0.0;
                    double proLat = profile?.Address?.Latitude ?? 0.0;
                    double proLon = profile?.Address?.Longitude ?? 0.0;

                    if (Math.Abs(proLat) < 0.001 && Math.Abs(proLon) < 0.001 && profile?.Address?.Location?.Coordinates?.Length == 2)
                    {
                        proLon = profile.Address.Location.Coordinates[0];
                        proLat = profile.Address.Location.Coordinates[1];
                    }

                    if (Math.Abs(proLat) > Math.Abs(proLon) && proLon > -30 && proLat < -30)
                    {
                        (proLat, proLon) = (proLon, proLat);
                    }

                    if (hasCustomerLoc && (Math.Abs(proLat) > 0.001 || Math.Abs(proLon) > 0.001))
                    {
                        distKm = CalculateDistanceKm(latitude, longitude, proLat, proLon);
                        int radius = (profile?.Address?.ServiceRadiusKm > 0) ? profile.Address.ServiceRadiusKm : 25;
                        if (distKm > radius && profUsers.Count > 1)
                        {
                            continue;
                        }
                    }

                    decimal basePrice = 150m;
                    List<string> serviceNames = [];
                    if (profile?.Services != null && profile.Services.Count > 0)
                    {
                        var sWithPrice = profile.Services.FirstOrDefault(s => s.Price > 0);
                        if (sWithPrice != null) basePrice = sWithPrice.Price;
                        serviceNames = profile.Services
                            .Select(s => s.ServiceName)
                            .Where(n => !string.IsNullOrWhiteSpace(n))
                            .ToList();
                    }
                    if (serviceNames.Count == 0 && !string.IsNullOrWhiteSpace(profile?.Profession))
                    {
                        serviceNames.Add(profile.Profession);
                    }

                    string profession = !string.IsNullOrWhiteSpace(profile?.Profession) ? profile.Profession : "Profissional";
                    string avatarUrl = !string.IsNullOrWhiteSpace(u.Photo) ? u.Photo : (!string.IsNullOrWhiteSpace(profile?.IdentitySelfieUrl) ? profile.IdentitySelfieUrl : "");

                    usersResult.Add(new
                    {
                        id = u.Id,
                        name = !string.IsNullOrWhiteSpace(u.Name) ? u.Name : "Profissional",
                        profession = profession,
                        avatarUrl = avatarUrl,
                        role = u.Role.ToString(),
                        distanciaKm = Math.Round(distKm, 1),
                        isAvailable = profile?.IsAvailableNow ?? true,
                        isVerified = true,
                        rating = (profile?.Rating > 0) ? profile.Rating : 5.0,
                        reviewCount = profile?.ReviewCount ?? 0,
                        completedServicesCount = profile?.CompletedServicesCount ?? 0,
                        region = !string.IsNullOrWhiteSpace(profile?.Address?.City) ? $"{profile.Address.City}, {profile.Address.State}" : "",
                        highlightBadge = (profile?.Badges != null && profile.Badges.Count > 0) ? profile.Badges.First() : "",
                        basePrice = basePrice,
                        bio = profile?.Bio ?? "",
                        offeredServices = serviceNames,
                        services = profile?.Services?.Select(s => new { serviceName = s.ServiceName, price = s.Price, priceType = s.PriceType }) ?? []
                    });
                }

                usersResult = usersResult.OrderBy(x => (double)x.distanciaKm).ToList();

                Console.WriteLine($"[GetProfessionalAvailability] Encontrados {usersResult.Count} profissionais para {date:yyyy-MM-dd} {hour}");

                return new(usersResult, 200, "Profissionais listados com sucesso");
            }
            catch (Exception ex)
            {
                return new([], 200, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        private static double CalculateDistanceKm(double lat1, double lon1, double lat2, double lon2)
        {
            if (Math.Abs(lat1) < 0.0001 && Math.Abs(lon1) < 0.0001) return 0.0;
            if (Math.Abs(lat2) < 0.0001 && Math.Abs(lon2) < 0.0001) return 0.0;

            const double R = 6371.0;
            double dLat = (lat2 - lat1) * Math.PI / 180.0;
            double dLon = (lon2 - lon1) * Math.PI / 180.0;
            double rLat1 = lat1 * Math.PI / 180.0;
            double rLat2 = lat2 * Math.PI / 180.0;

            double a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                       Math.Sin(dLon / 2) * Math.Sin(dLon / 2) * Math.Cos(rLat1) * Math.Cos(rLat2);
            double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
            return R * c;
        }

        private static bool TryParseTime(string? timeStr, out TimeSpan time)
        {
            time = TimeSpan.Zero;
            if (string.IsNullOrWhiteSpace(timeStr)) return false;

            if (TimeSpan.TryParse(timeStr.Trim(), out time)) return true;

            var parts = timeStr.Trim().Split(':');
            if (parts.Length >= 2 && int.TryParse(parts[0], out var h) && int.TryParse(parts[1], out var m))
            {
                time = new TimeSpan(h, m, 0);
                return true;
            }

            return false;
        }

        private static bool IsProfessionalWorkingAt(ProfileProfessional? profile, DateTime date, string hour)
        {
            if (profile == null || profile.WorkingHours == null || profile.WorkingHours.Count == 0)
                return true;

            int targetDayOfWeek = date.DayOfWeek switch
            {
                DayOfWeek.Monday => 0,
                DayOfWeek.Tuesday => 1,
                DayOfWeek.Wednesday => 2,
                DayOfWeek.Thursday => 3,
                DayOfWeek.Friday => 4,
                DayOfWeek.Saturday => 5,
                DayOfWeek.Sunday => 6,
                _ => 0
            };

            var matchingDay = profile.WorkingHours.FirstOrDefault(w => w.DayOfWeek == targetDayOfWeek);
            if (matchingDay == null)
            {
                string[] prefixes = ["seg", "ter", "qua", "qui", "sex", "sáb", "dom"];
                string targetPrefix = prefixes[targetDayOfWeek];
                matchingDay = profile.WorkingHours.FirstOrDefault(w =>
                    !string.IsNullOrWhiteSpace(w.DayName) && w.DayName.ToLower().Contains(targetPrefix));
            }

            if (matchingDay == null) return true;

            if (!matchingDay.IsActive) return false;

            if (string.IsNullOrWhiteSpace(hour)) return true;

            if (!TryParseTime(hour, out var requestedTime)) return true;

            string startHourStr = !string.IsNullOrWhiteSpace(matchingDay.StartHour) ? matchingDay.StartHour : "08:00";
            string endHourStr = !string.IsNullOrWhiteSpace(matchingDay.EndHour) ? matchingDay.EndHour : "18:00";

            if (TryParseTime(startHourStr, out var startTime) && requestedTime < startTime)
                return false;

            if (TryParseTime(endHourStr, out var endTime) && requestedTime >= endTime)
                return false;

            if (TryParseTime(matchingDay.BreakStart, out var breakStart) && TryParseTime(matchingDay.BreakEnd, out var breakEnd))
            {
                if (requestedTime >= breakStart && requestedTime < breakEnd)
                    return false;
            }

            return true;
        }

        public async Task<ResponseApi<ProfileProfessional?>> SaveAsync(CreateProfileProfessionalRequest request, string userId)
        {
            try
            {
                if (request.Address?.Location?.Coordinates != null && request.Address.Location.Coordinates.Length == 2)
                {
                    var c0 = request.Address.Location.Coordinates[0];
                    var c1 = request.Address.Location.Coordinates[1];
                    if (c0 > c1 && c1 < -30)
                    {
                        request.Address.Location.Coordinates = [c1, c0];
                    }
                }

                var effectiveUserId = string.IsNullOrWhiteSpace(request.UserId) ? userId : request.UserId;
                var existing = await repository.GetByUserIdAsync(effectiveUserId);
                ProfileProfessional? resultProfile = null;

                if (existing is not null)
                {
                    existing.Profession = request.Profession;
                    existing.Bio = request.Bio;
                    existing.ExperienceYears = request.ExperienceYears;
                    existing.IsAvailableNow = request.IsAvailableNow;
                    existing.IsProfileCompleted = true;
                    if (!string.IsNullOrWhiteSpace(request.IdentityDocumentType)) existing.IdentityDocumentType = request.IdentityDocumentType;
                    if (!string.IsNullOrWhiteSpace(request.IdentityDocumentNumber)) existing.IdentityDocumentNumber = request.IdentityDocumentNumber;
                    if (!string.IsNullOrWhiteSpace(request.IdentityDocumentFrontUrl)) existing.IdentityDocumentFrontUrl = request.IdentityDocumentFrontUrl;
                    if (!string.IsNullOrWhiteSpace(request.IdentityDocumentBackUrl)) existing.IdentityDocumentBackUrl = request.IdentityDocumentBackUrl;
                    if (!string.IsNullOrWhiteSpace(request.IdentityVerificationStatus))
                    {
                        existing.IdentityVerificationStatus = request.IdentityVerificationStatus;
                    }
                    else if (string.IsNullOrWhiteSpace(existing.IdentityVerificationStatus))
                    {
                        existing.IdentityVerificationStatus = "Pending";
                    }

                    if (!string.IsNullOrWhiteSpace(request.IdentityVerificationNotes))
                    {
                        existing.IdentityVerificationNotes = request.IdentityVerificationNotes;
                    }

                    existing.Address = request.Address ?? existing.Address;
                    existing.Services = request.Services ?? existing.Services;
                    existing.WorkingHours = request.WorkingHours ?? existing.WorkingHours;
                    existing.PortfolioPhotos = request.PortfolioPhotos ?? existing.PortfolioPhotos;
                    existing.UpdatedAt = DateTime.UtcNow;
                    existing.UpdatedBy = userId;

                    resultProfile = await repository.UpdateAsync(existing);
                }
                else
                {
                    var entity = new ProfileProfessional
                    {
                        UserId = effectiveUserId,
                        Profession = request.Profession,
                        Bio = request.Bio,
                        ExperienceYears = request.ExperienceYears,
                        IsAvailableNow = request.IsAvailableNow,
                        IsProfileCompleted = true,
                        IdentityDocumentType = request.IdentityDocumentType,
                        IdentityDocumentNumber = request.IdentityDocumentNumber,
                        IdentityDocumentFrontUrl = request.IdentityDocumentFrontUrl,
                        IdentityDocumentBackUrl = request.IdentityDocumentBackUrl,
                        IdentitySelfieUrl = request.IdentitySelfieUrl,
                        IdentityVerificationStatus = !string.IsNullOrWhiteSpace(request.IdentityVerificationStatus)
                            ? request.IdentityVerificationStatus
                            : "Pending",
                        IdentityVerificationNotes = request.IdentityVerificationNotes ?? string.Empty,
                        Address = request.Address ?? new(),
                        Services = request.Services ?? [],
                        WorkingHours = request.WorkingHours ?? [],
                        PortfolioPhotos = request.PortfolioPhotos ?? [],
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = userId,
                        UpdatedAt = DateTime.UtcNow,
                        UpdatedBy = userId,

                    };

                    resultProfile = await repository.CreateAsync(entity);
                }

                await UpsertApprovalRecordAsync(
                    effectiveUserId,
                    request.IdentityDocumentType,
                    request.IdentityDocumentNumber,
                    request.IdentityDocumentFrontUrl,
                    request.IdentityDocumentBackUrl,
                    request.IdentitySelfieUrl
                );

                return new(resultProfile, 200, "Perfil profissional salvo com sucesso");
            }
            catch (Exception ex)
            {
                System.Console.WriteLine(ex.Message);
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<bool>> UpdateAvailabilityAsync(string userId, bool isAvailable)
        {
            try
            {
                var success = await repository.UpdateAvailabilityAsync(userId, isAvailable);
                return new(success, 200, isAvailable ? "Disponibilidade ativada" : "Disponibilidade desativada");
            }
            catch (Exception ex)
            {
                return new(false, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<bool>> SaveIdentityVerificationAsync(
            string userId,
            string docType,
            string docNumber,
            string frontUrl,
            string backUrl,
            string selfieUrl)
        {
            try
            {
                var success = await repository.UpdateIdentityVerificationAsync(userId, docType, docNumber, frontUrl, backUrl, selfieUrl);
                await UpsertApprovalRecordAsync(userId, docType, docNumber, frontUrl, backUrl, selfieUrl);
                return new(success, 200, "Documentos para validação de identidade enviados com sucesso");
            }
            catch (Exception ex)
            {
                return new(false, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        private async Task UpsertApprovalRecordAsync(
            string userId,
            string docType,
            string docNumber,
            string frontUrl,
            string backUrl,
            string selfieUrl)
        {
            try
            {
                var existingApproval = await appDbContext.Approvals
                    .Find(x => !x.Deleted && x.ProfissionalId == userId)
                    .FirstOrDefaultAsync();

                if (existingApproval != null)
                {
                    if (!string.IsNullOrWhiteSpace(docType)) existingApproval.DocumentType = docType;
                    if (!string.IsNullOrWhiteSpace(docNumber)) existingApproval.DocumentNumber = docNumber;
                    if (!string.IsNullOrWhiteSpace(frontUrl)) existingApproval.RgFrontUrl = frontUrl;
                    if (!string.IsNullOrWhiteSpace(backUrl)) existingApproval.RgBackUrl = backUrl;
                    if (!string.IsNullOrWhiteSpace(selfieUrl)) existingApproval.SelfieUrl = selfieUrl;
                    existingApproval.Status = "analysis";
                    existingApproval.Approved = false;
                    existingApproval.UpdatedAt = DateTime.UtcNow;

                    await appDbContext.Approvals.ReplaceOneAsync(x => x.Id == existingApproval.Id, existingApproval);
                }
                else
                {
                    var newApproval = new Approval
                    {
                        ProfissionalId = userId,
                        DocumentType = string.IsNullOrWhiteSpace(docType) ? "CNH" : docType,
                        DocumentNumber = docNumber ?? string.Empty,
                        RgFrontUrl = frontUrl ?? string.Empty,
                        RgBackUrl = backUrl ?? string.Empty,
                        SelfieUrl = selfieUrl ?? string.Empty,
                        Status = "analysis",
                        Approved = false,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };

                    await appDbContext.Approvals.InsertOneAsync(newApproval);
                }
            }
            catch
            {
            }
        }
    }
}
