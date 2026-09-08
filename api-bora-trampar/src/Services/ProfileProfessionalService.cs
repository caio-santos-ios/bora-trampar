using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using MongoDB.Bson;
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
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
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
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
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
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }
        public async Task<ResponseApi<List<dynamic>>> GetProfessionalAvailabilityAsync(DateTime date, string hour, double latitude, double longitude)
        {
            try
            {
                List<BsonDocument> pipeline =
                [
                    new("$geoNear", new BsonDocument
                    {
                        { "near", new BsonDocument
                            {
                                { "type", "Point" },
                                { "coordinates", new BsonArray { longitude, latitude } }
                            }
                        },
                        { "distanceField", "distanciaMetros" },
                        { "spherical", true },
                        { "key", "address.location" }
                    }),
                    new("$addFields", new BsonDocument("distanciaKm",
                        new BsonDocument("$divide", new BsonArray { "$distanciaMetros", 1000 })) ),
                    new("$match", new BsonDocument
                    {
                        { "$expr", new BsonDocument("$lte", new BsonArray { "$distanciaKm", "$address.service_radius_km" }) }
                    }),
                    new("$lookup", new BsonDocument
                    {
                        {"from", "users"},
                        {"let", new BsonDocument("userId", "$user_id")},
                        {"pipeline", new BsonArray
                            {
                                new BsonDocument("$match", new BsonDocument("$expr",
                                    new BsonDocument("$eq", new BsonArray { new BsonDocument("$toString", "$_id"), "$$userId" })
                                ))
                            }
                        },
                        {"as", "user_lookup"}
                    }),
                    new("$unwind", "$user_lookup"),
                    new("$match", new BsonDocument
                    {
                        {"user_lookup.deleted", false},
                        {"user_lookup.blocked", false},
                        {"user_lookup.confirm_account", true},
                        {"is_available_now", true},
                        {"user_lookup.role", "Professional"}
                    }),
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", new BsonDocument("$toString", "$user_lookup._id")},
                        {"name", "$user_lookup.name"},
                        {"role", "$user_lookup.role"},
                        {"avatarUrl", new BsonDocument("$ifNull", new BsonArray {
                            "$user_lookup.photo",
                            new BsonDocument("$ifNull", new BsonArray {
                                "$photo",
                                new BsonDocument("$ifNull", new BsonArray {
                                    new BsonDocument("$arrayElemAt", new BsonArray { "$portfolio_photos", 0 }),
                                    ""
                                })
                            })
                        })},
                        {"profession", 1},
                        {"bio", new BsonDocument("$ifNull", new BsonArray { "$bio", "" })},
                        {"services", new BsonDocument("$ifNull", new BsonArray { "$services", new BsonArray() })},
                        {"rating", new BsonDocument("$ifNull", new BsonArray { "$rating", 5.0 })},
                        {"review_count", new BsonDocument("$ifNull", new BsonArray { "$review_count", 0 })},
                        {"completed_services_count", new BsonDocument("$ifNull", new BsonArray { "$completed_services_count", 0 })},
                        {"badges", new BsonDocument("$ifNull", new BsonArray { "$badges", new BsonArray() })},
                        {"address", 1},
                        {"distanciaKm", 1},
                        {"working_hours", new BsonDocument("$ifNull", new BsonArray { "$working_hours", "$workingHours" })}
                    }),
                    new("$sort", new BsonDocument { { "distanciaKm", 1 } } )
                ];

                List<BsonDocument> candidateDocs = await appDbContext.ProfileProfessionals
                    .Aggregate<BsonDocument>(pipeline)
                    .ToListAsync();

                if (candidateDocs.Count == 0)
                {
                    return new([], 200, "Profissionais listados com sucesso");
                }

                var availableCandidates = candidateDocs
                    .Where(doc => IsProfessionalWorkingAt(doc, date, hour))
                    .ToList();

                if (availableCandidates.Count == 0)
                {
                    return new([], 200, "Nenhum profissional disponível para o horário informado");
                }

                var candidateIds = availableCandidates
                    .Select(d => d.GetValue("id", "").AsString)
                    .Where(id => !string.IsNullOrEmpty(id))
                    .ToList();

                var canceledStatuses = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
                {
                    "cancelled", "canceled", "declined", "cancelado", "recusado"
                };

                var searchStart = date.Date.AddDays(-1);
                var searchEnd = date.Date.AddDays(2);

                var existingAppointments = await appDbContext.Appointments
                    .Find(a => !a.Deleted
                            && candidateIds.Contains(a.ProfissionalId)
                            && a.Date >= searchStart
                            && a.Date < searchEnd)
                    .ToListAsync();

                var busyProfessionalIds = new HashSet<string>();
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

                List<dynamic> users = [];
                foreach (var doc in availableCandidates)
                {
                    string profId = doc.GetValue("id", "").AsString;
                    if (busyProfessionalIds.Contains(profId))
                        continue;

                    double dist = 0.0;
                    if (doc.Contains("distanciaKm"))
                    {
                        var distVal = doc["distanciaKm"];
                        dist = distVal.IsDouble ? distVal.AsDouble : distVal.ToDouble();
                    }

                    string avatarUrl = doc.Contains("avatarUrl") && !doc["avatarUrl"].IsBsonNull
                        ? doc["avatarUrl"].AsString
                        : "";

                    string bio = doc.Contains("bio") && !doc["bio"].IsBsonNull
                        ? doc["bio"].AsString
                        : "";

                    decimal basePrice = 0m;
                    List<dynamic> servicesList = [];
                    if (doc.Contains("services") && doc["services"].IsBsonArray)
                    {
                        foreach (var s in doc["services"].AsBsonArray)
                        {
                            if (s.IsBsonDocument)
                            {
                                var sDoc = s.AsBsonDocument;
                                decimal sPrice = 0m;
                                if (sDoc.Contains("price"))
                                {
                                    var pVal = sDoc["price"];
                                    if (pVal.IsDecimal128) sPrice = (decimal)pVal.AsDecimal128;
                                    else if (pVal.IsDouble) sPrice = (decimal)pVal.AsDouble;
                                    else if (pVal.IsInt32) sPrice = pVal.AsInt32;
                                    else if (pVal.IsInt64) sPrice = pVal.AsInt64;
                                }

                                string pType = sDoc.GetValue("price_type", sDoc.GetValue("priceType", "Diária")).AsString;
                                string sName = sDoc.GetValue("service_name", sDoc.GetValue("serviceName", "")).AsString;
                                string catId = sDoc.GetValue("category_id", sDoc.GetValue("categoryId", "")).AsString;
                                string catName = sDoc.GetValue("category_name", sDoc.GetValue("categoryName", "")).AsString;
                                string servId = sDoc.GetValue("service_id", sDoc.GetValue("serviceId", "")).AsString;

                                servicesList.Add(new
                                {
                                    serviceId = servId,
                                    serviceName = sName,
                                    categoryId = catId,
                                    categoryName = catName,
                                    price = sPrice,
                                    priceType = pType
                                });

                                if (basePrice == 0m && sPrice > 0m)
                                {
                                    basePrice = sPrice;
                                }
                                else if (string.Equals(pType, "Diária", StringComparison.OrdinalIgnoreCase) && sPrice > 0m)
                                {
                                    basePrice = sPrice;
                                }
                            }
                        }
                    }

                    double rating = 5.0;
                    if (doc.Contains("rating") && !doc["rating"].IsBsonNull)
                    {
                        var rVal = doc["rating"];
                        rating = rVal.IsDouble ? rVal.AsDouble : (rVal.IsInt32 ? rVal.AsInt32 : (rVal.IsDecimal128 ? (double)rVal.AsDecimal128 : 5.0));
                    }

                    int reviewCount = 0;
                    if (doc.Contains("review_count") && !doc["review_count"].IsBsonNull)
                    {
                        var rcVal = doc["review_count"];
                        reviewCount = rcVal.IsInt32 ? rcVal.AsInt32 : (rcVal.IsInt64 ? (int)rcVal.AsInt64 : 0);
                    }

                    int completedServicesCount = 0;
                    if (doc.Contains("completed_services_count") && !doc["completed_services_count"].IsBsonNull)
                    {
                        var csVal = doc["completed_services_count"];
                        completedServicesCount = csVal.IsInt32 ? csVal.AsInt32 : (csVal.IsInt64 ? (int)csVal.AsInt64 : 0);
                    }

                    string region = "";
                    if (doc.Contains("address") && doc["address"].IsBsonDocument)
                    {
                        var addrDoc = doc["address"].AsBsonDocument;
                        string city = addrDoc.GetValue("city", "").AsString;
                        string state = addrDoc.GetValue("state", "").AsString;
                        if (!string.IsNullOrEmpty(city) && !string.IsNullOrEmpty(state))
                            region = $"{city} - {state}";
                        else if (!string.IsNullOrEmpty(city))
                            region = city;
                    }

                    string badge = "";
                    if (doc.Contains("badges") && doc["badges"].IsBsonArray && doc["badges"].AsBsonArray.Count > 0)
                    {
                        badge = doc["badges"].AsBsonArray[0].AsString;
                    }

                    users.Add(new
                    {
                        id = profId,
                        name = doc.GetValue("name", "").AsString,
                        profession = doc.GetValue("profession", "").AsString,
                        avatarUrl,
                        photo = avatarUrl,
                        role = doc.GetValue("role", "").AsString,
                        distanciaKm = Math.Round(dist, 1),
                        isAvailable = true,
                        isVerified = true,
                        rating,
                        reviewCount,
                        completedServicesCount,
                        region,
                        highlightBadge = badge,
                        bio,
                        basePrice,
                        services = servicesList
                    });
                }

                return new(users, 200, "Profissionais listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
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

        private static bool IsProfessionalWorkingAt(BsonDocument doc, DateTime date, string hour)
        {
            BsonArray? workingHours = null;
            if (doc.Contains("working_hours") && doc["working_hours"].IsBsonArray)
                workingHours = doc["working_hours"].AsBsonArray;
            else if (doc.Contains("workingHours") && doc["workingHours"].IsBsonArray)
                workingHours = doc["workingHours"].AsBsonArray;

            if (workingHours == null || workingHours.Count == 0)
                return true;

            // Segunda = 0, Terça = 1, ..., Domingo = 6
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

            BsonDocument? matchingDay = null;
            foreach (var item in workingHours)
            {
                if (!item.IsBsonDocument) continue;
                var dayDoc = item.AsBsonDocument;

                int dayIndex = -1;
                if (dayDoc.Contains("day_of_week") && (dayDoc["day_of_week"].IsInt32 || dayDoc["day_of_week"].IsInt64))
                    dayIndex = dayDoc["day_of_week"].ToInt32();
                else if (dayDoc.Contains("dayOfWeek") && (dayDoc["dayOfWeek"].IsInt32 || dayDoc["dayOfWeek"].IsInt64))
                    dayIndex = dayDoc["dayOfWeek"].ToInt32();

                if (dayIndex == targetDayOfWeek)
                {
                    matchingDay = dayDoc;
                    break;
                }
            }

            if (matchingDay == null)
            {
                string[] prefixes = ["seg", "ter", "qua", "qui", "sex", "sáb", "dom"];
                string targetPrefix = prefixes[targetDayOfWeek];

                foreach (var item in workingHours)
                {
                    if (!item.IsBsonDocument) continue;
                    var dayDoc = item.AsBsonDocument;
                    string dayName = "";
                    if (dayDoc.Contains("day_name") && dayDoc["day_name"].IsString)
                        dayName = dayDoc["day_name"].AsString.ToLower();
                    else if (dayDoc.Contains("dayName") && dayDoc["dayName"].IsString)
                        dayName = dayDoc["dayName"].AsString.ToLower();

                    if (dayName.Contains(targetPrefix))
                    {
                        matchingDay = dayDoc;
                        break;
                    }
                }
            }

            if (matchingDay == null) return true;

            bool isActive = true;
            if (matchingDay.Contains("is_active"))
                isActive = matchingDay["is_active"].ToBoolean();
            else if (matchingDay.Contains("isActive"))
                isActive = matchingDay["isActive"].ToBoolean();

            if (!isActive) return false;

            if (string.IsNullOrWhiteSpace(hour)) return true;

            if (!TryParseTime(hour, out var requestedTime)) return true;

            string startHourStr = matchingDay.Contains("start_hour") ? matchingDay["start_hour"].AsString :
                                  (matchingDay.Contains("startHour") ? matchingDay["startHour"].AsString : "08:00");
            string endHourStr = matchingDay.Contains("end_hour") ? matchingDay["end_hour"].AsString :
                                (matchingDay.Contains("endHour") ? matchingDay["endHour"].AsString : "18:00");

            if (TryParseTime(startHourStr, out var startTime) && requestedTime < startTime)
                return false;

            if (TryParseTime(endHourStr, out var endTime) && requestedTime >= endTime)
                return false;

            string breakStartStr = matchingDay.Contains("break_start") ? matchingDay["break_start"].AsString :
                                   (matchingDay.Contains("breakStart") ? matchingDay["breakStart"].AsString : "");
            string breakEndStr = matchingDay.Contains("break_end") ? matchingDay["break_end"].AsString :
                                 (matchingDay.Contains("breakEnd") ? matchingDay["breakEnd"].AsString : "");

            if (TryParseTime(breakStartStr, out var breakStart) && TryParseTime(breakEndStr, out var breakEnd))
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