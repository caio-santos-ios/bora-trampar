using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class ApprovalRepository(AppDbContext appDbContext) : IApprovalRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            if (pipeline != null && pipeline.Count > 0)
            {
                List<BsonDocument> list = await appDbContext.Approvals.Aggregate<BsonDocument>(pipeline).ToListAsync();
                return list.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).ToList();
            }

            var approvals = await appDbContext.Approvals
                .Find(x => !x.Deleted)
                .SortByDescending(x => x.CreatedAt)
                .ToListAsync();

            return approvals.Select(a => (dynamic)new
            {
                id = a.Id,
                _id = a.Id,
                profissionalId = a.ProfissionalId,
                profissional_id = a.ProfissionalId,
                documentType = a.DocumentType,
                document_type = a.DocumentType,
                documentNumber = a.DocumentNumber,
                document_number = a.DocumentNumber,
                rgFrontUrl = a.RgFrontUrl,
                rg_front_url = a.RgFrontUrl,
                rgBackUrl = a.RgBackUrl,
                rg_back_url = a.RgBackUrl,
                selfieUrl = a.SelfieUrl,
                selfie_url = a.SelfieUrl,
                status = a.Status,
                approved = a.Approved,
                reviewNotes = a.ReviewNotes,
                review_notes = a.ReviewNotes,
                reviewedBy = a.ReviewedBy,
                reviewed_by = a.ReviewedBy,
                reviewedAt = a.ReviewedAt,
                reviewed_at = a.ReviewedAt,
                createdAt = a.CreatedAt,
                created_at = a.CreatedAt,
                updatedAt = a.UpdatedAt,
                updated_at = a.UpdatedAt,
                deleted = a.Deleted
            }).ToList();
        }

        public async Task<Approval?> GetByIdAsync(string id)
        {
            if (string.IsNullOrWhiteSpace(id) || !ObjectId.TryParse(id, out _))
                return null;

            return await appDbContext.Approvals.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }

        public async Task<Approval?> CreateAsync(Approval entity)
        {
            await appDbContext.Approvals.InsertOneAsync(entity);
            return entity;
        }

        public async Task<Approval?> UpdateAsync(Approval entity)
        {
            await appDbContext.Approvals.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }

        public async Task<Approval> DeleteAsync(Approval entity)
        {
            await appDbContext.Approvals.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}
