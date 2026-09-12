using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Models;
using MongoDB.Driver;

namespace api_bora_trampar.src.Works
{
    public class ProfessionalAvailableNowWork(IServiceProvider serviceProvider, ILogger<ProfessionalAvailableNowWork> _logger) : BackgroundService
    {
        private static readonly TimeSpan CheckInterval = TimeSpan.FromSeconds(120);

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await ProcessDueNotifications(stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Erro no background worker de atualizar profissional disponivel.");
                }

                await Task.Delay(CheckInterval, stoppingToken);
            }
        }

        private async Task ProcessDueNotifications(CancellationToken ct)
        {
            using var scope = serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();

            await SendPendingNotificationsAsync(context);
        }

        private async Task SendPendingNotificationsAsync(AppDbContext context)
        {
            DateTime now = DateTime.UtcNow;
            TimeSpan time = now.TimeOfDay;
            TimeSpan timeBrasilia = time.Add(-TimeSpan.Parse("03:00"));

            List<ProfileProfessional> profileProfessionals = await context.ProfileProfessionals
                .Find(x => !x.Deleted && x.DateAvailableNowManual != null && x.WorkingHours.Where(w => w.DayOfWeek == GetIndexWeek(now.DayOfWeek.ToString())).Count() > 0)
                .ToListAsync();

            if (profileProfessionals.Count == 0) return;

            foreach (ProfileProfessional profileProfessional in profileProfessionals)
            {
                try
                {
                    if(profileProfessional.DateAvailableNowManual?.Date == now.Date) continue;

                    ProfessionalWorkingDay? workingDay = profileProfessional.WorkingHours.Where(x => x.DayOfWeek == GetIndexWeek(now.DayOfWeek.ToString())).FirstOrDefault();
                    if (workingDay is not null)
                    {
                        TimeSpan startHour = TimeSpan.Parse(workingDay.StartHour);
                        TimeSpan endHour = TimeSpan.Parse(workingDay.EndHour);
                        TimeSpan breakStart = TimeSpan.Parse(workingDay.BreakStart);
                        TimeSpan breakEnd = TimeSpan.Parse(workingDay.BreakEnd);
                        
                        if(timeBrasilia >= breakStart && timeBrasilia < breakEnd)
                        {
                            profileProfessional.IsAvailableNow = false;
                        }

                        if(timeBrasilia < startHour && timeBrasilia > endHour)
                        {
                            profileProfessional.IsAvailableNow = false;
                        }

                        if((timeBrasilia >= startHour && timeBrasilia < breakStart) || (timeBrasilia >= breakEnd && timeBrasilia < endHour))
                        {
                            profileProfessional.IsAvailableNow = true;
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Falha ao atualizar profissional disponivel {Id}", profileProfessional.Id);
                }
            }
        }

        private int GetIndexWeek(string week)
        {
            switch (week)
            {
                case "Saturday": return 0;
                default: return 0;
            }
        }
    }
}



