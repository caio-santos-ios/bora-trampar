using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;
using MongoDB.Driver;

namespace api_bora_trampar.src.Services
{
    public class ApprovalService(
        IApprovalRepository repository,
        AppDbContext appDbContext) : IApprovalService
    {
        public async Task<ResponseApi<List<dynamic>>> GetAllAsync()
        {
            try
            {
                var profiles = await appDbContext.ProfileProfessionals
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

                    var existing = await appDbContext.Approvals
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

                        await appDbContext.Approvals.InsertOneAsync(newApproval);
                    }
                }

                List<dynamic> approvals = await repository.GetAllAsync([]);
                return new(approvals, 200, "Aprovações listadas com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<Approval?>> GetByIdAsync(string id)
        {
            try
            {
                Approval? approval = await repository.GetByIdAsync(id);
                if (approval is null) return new(null, 404, "Aprovação não encontrada");

                return new(approval, 200, "Aprovação encontrada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<Approval?>> CreateAsync(CreateApprovalRequest request)
        {
            try
            {
                Approval approval = new()
                {
                    ProfissionalId = request.ProfissionalId,
                    DocumentType = request.DocumentType,
                    DocumentNumber = request.DocumentNumber,
                    RgFrontUrl = request.RgFrontUrl,
                    RgBackUrl = request.RgBackUrl,
                    SelfieUrl = request.SelfieUrl,
                    Status = request.Status,
                    Approved = request.Approved,
                    ReviewNotes = request.ReviewNotes,
                    ReviewedBy = request.ReviewedBy,
                    ReviewedAt = request.ReviewedAt,
                    CreatedAt = DateTime.UtcNow,
                    CreatedBy = request.CreatedBy,
                    UpdatedAt = DateTime.UtcNow,
                    UpdatedBy = request.UpdatedBy
                };

                Approval? created = await repository.CreateAsync(approval);
                if (created is null) return new(null, 400, "Falha ao criar aprovação");

                return new(created, 201, "Aprovação criada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<Approval?>> UpdateAsync(UpdateApprovalRequest request)
        {
            try
            {
                Approval? existing = null;

                if (!string.IsNullOrWhiteSpace(request.Id) && MongoDB.Bson.ObjectId.TryParse(request.Id, out _))
                {
                    existing = await repository.GetByIdAsync(request.Id);
                }

                if (existing == null && !string.IsNullOrWhiteSpace(request.ProfissionalId))
                {
                    existing = await appDbContext.Approvals
                        .Find(x => !x.Deleted && x.ProfissionalId == request.ProfissionalId)
                        .FirstOrDefaultAsync();
                }

                if (existing == null) return new(null, 404, "Aprovação não encontrada");

                var statusNorm = (request.Status ?? "").ToLower().Trim();
                var isApproved = request.Approved || statusNorm == "approved" || statusNorm == "approve";
                var isRejected = statusNorm == "rejected" || statusNorm == "reject";
                var isCorrection = statusNorm == "correction";

                if (!string.IsNullOrEmpty(request.ProfissionalId)) existing.ProfissionalId = request.ProfissionalId;
                if (!string.IsNullOrEmpty(request.DocumentType)) existing.DocumentType = request.DocumentType;
                if (!string.IsNullOrEmpty(request.DocumentNumber)) existing.DocumentNumber = request.DocumentNumber;
                if (!string.IsNullOrEmpty(request.RgFrontUrl)) existing.RgFrontUrl = request.RgFrontUrl;
                if (!string.IsNullOrEmpty(request.RgBackUrl)) existing.RgBackUrl = request.RgBackUrl;
                if (!string.IsNullOrEmpty(request.SelfieUrl)) existing.SelfieUrl = request.SelfieUrl;
                
                existing.Approved = isApproved;
                existing.Status = isApproved ? "approved" : isRejected ? "rejected" : isCorrection ? "correction" : "analysis";
                existing.ReviewNotes = request.ReviewNotes ?? string.Empty;
                existing.ReviewedBy = string.IsNullOrWhiteSpace(request.ReviewedBy) ? (string.IsNullOrWhiteSpace(request.UpdatedBy) ? "Admin" : request.UpdatedBy) : request.ReviewedBy;
                existing.ReviewedAt = DateTime.UtcNow.ToString("o");
                existing.UpdatedAt = DateTime.UtcNow;
                existing.UpdatedBy = request.UpdatedBy;

                Approval? approval = await repository.UpdateAsync(existing);
                if (approval is null) return new(null, 400, "Falha ao atualizar aprovação");

                var profile = await appDbContext.ProfileProfessionals
                    .Find(p => !p.Deleted && p.UserId == existing.ProfissionalId)
                    .FirstOrDefaultAsync();

                if (profile != null)
                {
                    if (isApproved)
                    {
                        profile.IdentityVerificationStatus = "Approved";
                    }
                    else if (isRejected)
                    {
                        profile.IdentityVerificationStatus = "Rejected";
                    }
                    else if (isCorrection)
                    {
                        profile.IdentityVerificationStatus = "Correction";
                    }
                    else
                    {
                        profile.IdentityVerificationStatus = "Pending";
                    }

                    profile.IdentityVerificationNotes = request.ReviewNotes ?? string.Empty;
                    profile.UpdatedAt = DateTime.UtcNow;
                    await appDbContext.ProfileProfessionals.ReplaceOneAsync(p => p.Id == profile.Id, profile);
                }

                return new(approval, 200, "Aprovação atualizada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<Approval?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                var existing = await repository.GetByIdAsync(request.Id);
                if (existing == null) return new(null, 404, "Aprovação não encontrada");
                existing.Deleted = true;
                existing.DeletedAt = DateTime.UtcNow;
                existing.DeletedBy = request.DeletedBy;
                Approval? approval = await repository.DeleteAsync(existing);
                if (approval is null) return new(null, 400, "Falha ao deletar aprovação");

                return new(approval, 200, "Aprovação deletada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }
    }
}
