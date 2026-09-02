using api_bora_trampar.src.Handlers;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Interfaces.Auth;
using api_bora_trampar.src.Interfaces.Dashboard;
using api_bora_trampar.src.Repositories;
using api_bora_trampar.src.Services;

namespace api_bora_trampar.src.Configuration
{
    public static class Build
    {
        public static void AddContext(this WebApplicationBuilder builder)
        {
            builder.Services.AddSingleton<AppDbContext>();
        }

        public static void AddBuilderServices(this WebApplicationBuilder builder)
        {
            builder.Services.AddTransient<IAuthService, AuthService>();
            builder.Services.AddTransient<IAuthRepository, AuthRepository>();

            builder.Services.AddTransient<IDashboardService, DashboardService>();
            builder.Services.AddTransient<IDashboardRepository, DashboardRepository>();

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

            builder.Services.AddTransient<IAsaasService, AsaasService>();

            builder.Services.AddTransient<IProfileProfessionalService, ProfileProfessionalService>();
            builder.Services.AddTransient<IProfileProfessionalRepository, ProfileProfessionalRepository>();

            builder.Services.AddTransient<ICloudinaryHandler, CloudinaryHandler>();
        }
    }
}