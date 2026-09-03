using System.Text.Json.Serialization;
using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    [BsonIgnoreExtraElements]
    public class ProfileProfessional : ModelBase
    {
        [BsonElement("user_id")]
        [JsonPropertyName("userId")]
        public string UserId { get; set; } = string.Empty;

        [BsonElement("profession")]
        [JsonPropertyName("profession")]
        public string Profession { get; set; } = string.Empty;

        [BsonElement("bio")]
        [JsonPropertyName("bio")]
        public string Bio { get; set; } = string.Empty;

        [BsonElement("experience_years")]
        [JsonPropertyName("experienceYears")]
        public int ExperienceYears { get; set; } = 0;

        [BsonElement("is_available_now")]
        [JsonPropertyName("isAvailableNow")]
        public bool IsAvailableNow { get; set; } = true;

        [BsonElement("is_profile_completed")]
        [JsonPropertyName("isProfileCompleted")]
        public bool IsProfileCompleted { get; set; } = false;

        [BsonElement("identity_document_type")]
        [JsonPropertyName("identityDocumentType")]
        public string IdentityDocumentType { get; set; } = string.Empty;

        [BsonElement("identity_document_number")]
        [JsonPropertyName("identityDocumentNumber")]
        public string IdentityDocumentNumber { get; set; } = string.Empty;

        [BsonElement("identity_document_front_url")]
        [JsonPropertyName("identityDocumentFrontUrl")]
        public string IdentityDocumentFrontUrl { get; set; } = string.Empty;

        [BsonElement("identity_document_back_url")]
        [JsonPropertyName("identityDocumentBackUrl")]
        public string IdentityDocumentBackUrl { get; set; } = string.Empty;

        [BsonElement("identity_selfie_url")]
        [JsonPropertyName("identitySelfieUrl")]
        public string IdentitySelfieUrl { get; set; } = string.Empty;

        [BsonElement("identity_verification_status")]
        [JsonPropertyName("identityVerificationStatus")]
        public string IdentityVerificationStatus { get; set; } = "Pending";

        [BsonElement("identity_verification_notes")]
        [JsonPropertyName("identityVerificationNotes")]
        public string IdentityVerificationNotes { get; set; } = string.Empty;

        [BsonElement("address")]
        [JsonPropertyName("address")]
        public ProfessionalAddress Address { get; set; } = new();

        [BsonElement("services")]
        [JsonPropertyName("services")]
        public List<ProfessionalServiceItem> Services { get; set; } = [];

        [BsonElement("working_hours")]
        [JsonPropertyName("workingHours")]
        public List<ProfessionalWorkingDay> WorkingHours { get; set; } = [];

        [BsonElement("portfolio_photos")]
        [JsonPropertyName("portfolioPhotos")]
        public List<string> PortfolioPhotos { get; set; } = [];

        [BsonElement("rating")]
        [JsonPropertyName("rating")]
        public double Rating { get; set; } = 0.0;

        [BsonElement("review_count")]
        [JsonPropertyName("reviewCount")]
        public int ReviewCount { get; set; } = 0;

        [BsonElement("completed_services_count")]
        [JsonPropertyName("completedServicesCount")]
        public int CompletedServicesCount { get; set; } = 0;

        [BsonElement("badges")]
        [JsonPropertyName("badges")]
        public List<string> Badges { get; set; } = [];
    }

    [BsonIgnoreExtraElements]
    public class ProfessionalAddress
    {
        [BsonElement("zip_code")]
        [JsonPropertyName("zipCode")]
        public string ZipCode { get; set; } = string.Empty;

        [BsonElement("street")]
        [JsonPropertyName("street")]
        public string Street { get; set; } = string.Empty;

        [BsonElement("number")]
        [JsonPropertyName("number")]
        public string Number { get; set; } = string.Empty;

        [BsonElement("complement")]
        [JsonPropertyName("complement")]
        public string Complement { get; set; } = string.Empty;

        [BsonElement("neighborhood")]
        [JsonPropertyName("neighborhood")]
        public string Neighborhood { get; set; } = string.Empty;

        [BsonElement("city")]
        [JsonPropertyName("city")]
        public string City { get; set; } = string.Empty;

        [BsonElement("state")]
        [JsonPropertyName("state")]
        public string State { get; set; } = string.Empty;

        [BsonElement("latitude")]
        [JsonPropertyName("latitude")]
        public double Latitude { get; set; } = 0.0;

        [BsonElement("longitude")]
        [JsonPropertyName("longitude")]
        public double Longitude { get; set; } = 0.0;

        [BsonElement("service_radius_km")]
        [JsonPropertyName("serviceRadiusKm")]
        public int ServiceRadiusKm { get; set; } = 25;
    }

    [BsonIgnoreExtraElements]
    public class ProfessionalServiceItem
    {
        [BsonElement("category_id")]
        [JsonPropertyName("categoryId")]
        public string CategoryId { get; set; } = string.Empty;

        [BsonElement("category_name")]
        [JsonPropertyName("categoryName")]
        public string CategoryName { get; set; } = string.Empty;

        [BsonElement("service_id")]
        [JsonPropertyName("serviceId")]
        public string ServiceId { get; set; } = string.Empty;

        [BsonElement("service_name")]
        [JsonPropertyName("serviceName")]
        public string ServiceName { get; set; } = string.Empty;

        [BsonElement("price")]
        [BsonRepresentation(MongoDB.Bson.BsonType.Decimal128, AllowTruncation = true)]
        [JsonPropertyName("price")]
        public decimal Price { get; set; } = 0m;

        [BsonElement("price_type")]
        [JsonPropertyName("priceType")]
        public string PriceType { get; set; } = "Diária";

        [BsonElement("estimated_minutes")]
        [JsonPropertyName("estimatedMinutes")]
        public int EstimatedMinutes { get; set; } = 480;

        [BsonElement("description")]
        [JsonPropertyName("description")]
        public string Description { get; set; } = string.Empty;
    }

    [BsonIgnoreExtraElements]
    public class ProfessionalWorkingDay
    {
        [BsonElement("day_of_week")]
        [JsonPropertyName("dayOfWeek")]
        public int DayOfWeek { get; set; }

        [BsonElement("day_name")]
        [JsonPropertyName("dayName")]
        public string DayName { get; set; } = string.Empty;

        [BsonElement("is_active")]
        [JsonPropertyName("isActive")]
        public bool IsActive { get; set; } = true;

        [BsonElement("start_hour")]
        [JsonPropertyName("startHour")]
        public string StartHour { get; set; } = "08:00";

        [BsonElement("end_hour")]
        [JsonPropertyName("endHour")]
        public string EndHour { get; set; } = "18:00";

        [BsonElement("break_start")]
        [JsonPropertyName("breakStart")]
        public string BreakStart { get; set; } = "12:00";

        [BsonElement("break_end")]
        [JsonPropertyName("breakEnd")]
        public string BreakEnd { get; set; } = "13:00";
    }
}