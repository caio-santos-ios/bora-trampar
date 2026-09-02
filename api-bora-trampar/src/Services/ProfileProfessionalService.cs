using api_bora_trampar.src.Configuration;
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
                    if (!string.IsNullOrWhiteSpace(request.IdentitySelfieUrl)) existing.IdentitySelfieUrl = request.IdentitySelfieUrl;
                    existing.IdentityVerificationStatus = "Pending";
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
                        IdentityVerificationStatus = "Pending",
                        IdentityVerificationNotes = string.Empty,
                        Address = request.Address ?? new(),
                        Services = request.Services ?? [],
                        WorkingHours = request.WorkingHours ?? [],
                        PortfolioPhotos = request.PortfolioPhotos ?? [],
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = userId,
                        UpdatedAt = DateTime.UtcNow,
                        UpdatedBy = userId
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
