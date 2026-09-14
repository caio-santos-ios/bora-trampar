using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Models;
using MongoDB.Driver;

namespace api_bora_trampar.src.Works
{
    public class AppointmentFinishWork(IServiceProvider serviceProvider, ILogger<AppointmentFinishWork> _logger) : BackgroundService
    {
        private static readonly TimeSpan CheckInterval = TimeSpan.FromSeconds(120);

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await ProcessFinishAppointment(stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Erro no background worker de atualizar profissional disponivel.");
                }

                await Task.Delay(CheckInterval, stoppingToken);
            }
        }

        private async Task ProcessFinishAppointment(CancellationToken ct)
        {
            using var scope = serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();

            await SendPendingNotificationsAsync(context);
        }

        private async Task SendPendingNotificationsAsync(AppDbContext context)
        {
            DateTime now = DateTime.UtcNow;

            List<Appointment> appointments = await context.Appointments
                .Find(x => !x.Deleted && x.Status == "FinishProfessional" && x.ProfessionalFinishAt <= now.AddDays(-2)) 
                .ToListAsync();

            if (appointments.Count == 0) return;

            foreach (Appointment appointment in appointments)
            {
                try
                {
                    appointment.Status = "Finish";
                    await context.Appointments.ReplaceOneAsync(x => x.Id.Equals(appointment), appointment);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Falha ao atualizar profissional disponivel {Id}", appointment.Id);
                }
            }
        }
    }
}



