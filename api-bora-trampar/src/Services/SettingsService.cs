using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using MongoDB.Driver;

namespace api_bora_trampar.src.Services
{
    public class SettingsService(AppDbContext appDbContext) : ISettingsService
    {
        public async Task<ResponseApi<PlatformSettings>> GetAsync()
        {
            try
            {
                var settings = await appDbContext.PlatformSettings
                    .Find(s => !s.Deleted)
                    .FirstOrDefaultAsync();

                if (settings == null)
                {
                    settings = new PlatformSettings();
                    await appDbContext.PlatformSettings.InsertOneAsync(settings);
                }

                return new(settings, 200, "Configurações obtidas com sucesso");
            }
            catch (Exception ex)
            {
                return new(new PlatformSettings(), 500, $"Erro ao obter configurações: {ex.Message}");
            }
        }

        public async Task<ResponseApi<PlatformSettings>> UpdateAsync(UpdateSettingsRequest request)
        {
            try
            {
                var settings = await appDbContext.PlatformSettings
                    .Find(s => !s.Deleted)
                    .FirstOrDefaultAsync();

                if (settings == null)
                {
                    settings = new PlatformSettings();
                }

                settings.PlatformFeePercentage = request.PlatformFeePercentage;
                settings.DisputeRetentionDays = request.DisputeRetentionDays;
                settings.RequireSelfieVerification = request.RequireSelfieVerification;
                settings.PixExpirationMinutes = request.PixExpirationMinutes;
                if (!string.IsNullOrWhiteSpace(request.PixProvider)) settings.PixProvider = request.PixProvider;
                if (!string.IsNullOrWhiteSpace(request.PixWebhookUrl)) settings.PixWebhookUrl = request.PixWebhookUrl;
                if (!string.IsNullOrWhiteSpace(request.SupportEmail)) settings.SupportEmail = request.SupportEmail;
                settings.MaintenanceMode = request.MaintenanceMode;
                settings.UpdatedAt = DateTime.UtcNow;

                if (string.IsNullOrEmpty(settings.Id))
                {
                    await appDbContext.PlatformSettings.InsertOneAsync(settings);
                }
                else
                {
                    await appDbContext.PlatformSettings.ReplaceOneAsync(s => s.Id == settings.Id, settings);
                }

                return new(settings, 200, "Configurações atualizadas com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Erro ao atualizar configurações: {ex.Message}");
            }
        }
    }
}
