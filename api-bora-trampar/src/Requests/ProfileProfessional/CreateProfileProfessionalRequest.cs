using System.Text.Json.Serialization;
using api_bora_trampar.src.Models;

namespace api_bora_trampar.src.Requests
{
    public class CreateProfileProfessionalRequest
    {
        [JsonPropertyName("userId")]
        public string UserId { get; set; } = string.Empty;

        [JsonPropertyName("profession")]
        public string Profession { get; set; } = string.Empty;

        [JsonPropertyName("bio")]
        public string Bio { get; set; } = string.Empty;

        [JsonPropertyName("experienceYears")]
        public int ExperienceYears { get; set; } = 0;

        [JsonPropertyName("isAvailableNow")]
        public bool IsAvailableNow { get; set; } = true;

        [JsonPropertyName("isProfileCompleted")]
        public bool IsProfileCompleted { get; set; } = true;

        [JsonPropertyName("identityDocumentType")]
        public string IdentityDocumentType { get; set; } = string.Empty;

        [JsonPropertyName("identityDocumentNumber")]
        public string IdentityDocumentNumber { get; set; } = string.Empty;

        [JsonPropertyName("identityDocumentFrontUrl")]
        public string IdentityDocumentFrontUrl { get; set; } = string.Empty;

        [JsonPropertyName("identityDocumentBackUrl")]
        public string IdentityDocumentBackUrl { get; set; } = string.Empty;

        [JsonPropertyName("identitySelfieUrl")]
        public string IdentitySelfieUrl { get; set; } = string.Empty;

        [JsonPropertyName("address")]
        public ProfessionalAddress Address { get; set; } = new();

        [JsonPropertyName("services")]
        public List<ProfessionalServiceItem> Services { get; set; } = [];

        [JsonPropertyName("workingHours")]
        public List<ProfessionalWorkingDay> WorkingHours { get; set; } = [];

        [JsonPropertyName("portfolioPhotos")]
        public List<string> PortfolioPhotos { get; set; } = [];

        [JsonPropertyName("updatedBy")]
        public string UpdatedBy { get; set; } = string.Empty;
    }

    public class UpdateProfileProfessionalRequest : CreateProfileProfessionalRequest
    {
        [JsonPropertyName("id")]
        public string Id { get; set; } = string.Empty;
    }
}
