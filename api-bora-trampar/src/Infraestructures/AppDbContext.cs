using api_bora_trampar.src.Models;
using MongoDB.Driver;

namespace api_bora_trampar.src.Configuration
{
    public class AppDbContext
    {
        private IMongoDatabase Database { get; }

        public AppDbContext()
        {
            try
            {
                string connectionString = Environment.GetEnvironmentVariable("MONGODB_CONNECTION") ?? "";
                string databaseName = Environment.GetEnvironmentVariable("DATABASE_NAME") ?? "";
                MongoClient client = new (connectionString);
                
                Database = client.GetDatabase(databaseName);
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to connect to database. Error: {ex.Message}");
            }
        }

        public IMongoCollection<User> Users => Database.GetCollection<User>("users");
        public IMongoCollection<Category> Categories => Database.GetCollection<Category>("categories");
        public IMongoCollection<Models.Services> Services => Database.GetCollection<Models.Services>("services");
        public IMongoCollection<Appointment> Appointments => Database.GetCollection<Appointment>("appointments");
        public IMongoCollection<Approval> Approvals => Database.GetCollection<Approval>("approvals");
        public IMongoCollection<Document> Documents => Database.GetCollection<Document>("documents");
        public IMongoCollection<Payment> Payments => Database.GetCollection<Payment>("payments");
        public IMongoCollection<Reviews> Reviews => Database.GetCollection<Reviews>("reviews");
        public IMongoCollection<ProfileProfessional> ProfileProfessionals => Database.GetCollection<ProfileProfessional>("profile_professionals");
    }
}
