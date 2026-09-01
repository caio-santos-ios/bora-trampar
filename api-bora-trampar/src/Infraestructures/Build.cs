using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Interfaces.Auth;
using api_bora_trampar.src.Repositories;
using api_bora_trampar.src.Services;
using CloudinaryDotNet;

namespace api_bora_trampar.src.Configuration
{
    public static class Build
    {
        public static void AddBuilderConfiguration(this WebApplicationBuilder builder)
        {
            AppDbContext.ConnectionString = Environment.GetEnvironmentVariable("CONNECTION_STRING") ?? "";
            AppDbContext.DatabaseName     = Environment.GetEnvironmentVariable("DATABASE_NAME")     ?? "";
            AppDbContext.IsSSL = !string.IsNullOrEmpty(Environment.GetEnvironmentVariable("IS_SSL"))
                && Convert.ToBoolean(Environment.GetEnvironmentVariable("IS_SSL"));
        }

        public static void AddContext(this WebApplicationBuilder builder)
        {
            builder.Services.AddSingleton<AppDbContext>();
        }

        public static void AddBuilderServices(this WebApplicationBuilder builder)
        {
            builder.Services.AddTransient<IAuthService, AuthService>();

            builder.Services.AddTransient<IUserService, UserService>();
            builder.Services.AddTransient<IUserRepository, UserRepository>();

            builder.Services.AddTransient<ICategoryService, CategoryService>();
            builder.Services.AddTransient<ICategoryRepository, CategoryRepository>();

            builder.Services.AddTransient<IServicesService, ServicesService>();
            builder.Services.AddTransient<IServicesRepository, ServicesRepository>();

            builder.Services.AddTransient<IAppointmentService, AppointmentService>();
            builder.Services.AddTransient<IAppointmentRepository, AppointmentRepository>();

            builder.Services.AddTransient<IApprovalService, ApprovalService>();
            builder.Services.AddTransient<IApprovalRepository, ApprovalRepository>();

            builder.Services.AddTransient<IDocumentService, DocumentService>();
            builder.Services.AddTransient<IDocumentRepository, DocumentRepository>();

            builder.Services.AddTransient<IPaymentService, PaymentService>();
            builder.Services.AddTransient<IPaymentRepository, PaymentRepository>();

            builder.Services.AddTransient<IReviewsService, ReviewsService>();
            builder.Services.AddTransient<IReviewsRepository, ReviewsRepository>();

            Account account = new(
                Environment.GetEnvironmentVariable("CLOUDINARY_CLOUD_NAME"),
                Environment.GetEnvironmentVariable("CLOUDINARY_API_KEY"),
                Environment.GetEnvironmentVariable("CLOUDINARY_API_SECRET")
            );
            builder.Services.AddSingleton(new Cloudinary(account));
        }
    }
}