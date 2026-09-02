using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class ProfileProfessionalRepository(AppDbContext appDbContext) : IProfileProfessionalRepository
    {
        public async Task<ProfileProfessional?> GetByUserIdAsync(string userId)
        {
            return await appDbContext.ProfileProfessionals
                .Find(x => !x.Deleted && x.UserId == userId)
                .FirstOrDefaultAsync();
        }

        public async Task<ProfileProfessional?> GetByIdAsync(string id)
        {
            return await appDbContext.ProfileProfessionals
                .Find(x => !x.Deleted && x.Id == id)
                .FirstOrDefaultAsync();
        }

        public async Task<ProfileProfessional?> CreateAsync(ProfileProfessional entity)
        {
            await appDbContext.ProfileProfessionals.InsertOneAsync(entity);
            return entity;
        }

        public async Task<ProfileProfessional?> UpdateAsync(ProfileProfessional entity)
        {
            await appDbContext.ProfileProfessionals.ReplaceOneAsync(x => x.Id == entity.Id, entity);
            return entity;
        }

        public async Task<bool> UpdateAvailabilityAsync(string userId, bool isAvailable)
        {
            var update = Builders<ProfileProfessional>.Update
                .Set(x => x.IsAvailableNow, isAvailable)
                .Set(x => x.UpdatedAt, DateTime.UtcNow);

            var result = await appDbContext.ProfileProfessionals
                .UpdateOneAsync(x => !x.Deleted && x.UserId == userId, update);

            return result.ModifiedCount > 0;
        }

        public async Task<bool> UpdateIdentityVerificationAsync(
            string userId,
            string docType,
            string docNumber,
            string frontUrl,
            string backUrl,
            string selfieUrl)
        {
            var update = Builders<ProfileProfessional>.Update
                .Set(x => x.IdentityDocumentType, docType)
                .Set(x => x.IdentityDocumentNumber, docNumber)
                .Set(x => x.IdentityDocumentFrontUrl, frontUrl)
                .Set(x => x.IdentityDocumentBackUrl, backUrl)
                .Set(x => x.IdentitySelfieUrl, selfieUrl)
                .Set(x => x.IdentityVerificationStatus, "Pending")
                .Set(x => x.UpdatedAt, DateTime.UtcNow);

            var result = await appDbContext.ProfileProfessionals
                .UpdateOneAsync(x => !x.Deleted && x.UserId == userId, update);

            return result.ModifiedCount > 0;
        }
    }
}
