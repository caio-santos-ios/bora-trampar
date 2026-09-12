using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Models;
using FirebaseAdmin.Messaging;
using MongoDB.Driver;
using AppNotification = api_bora_trampar.src.Models.Notification;

namespace api_bora_trampar.src.Works
{
    public class PushNotificationWork(IServiceProvider serviceProvider, ILogger<PushNotificationWork> _logger) : BackgroundService
    {
        private static readonly TimeSpan CheckInterval = TimeSpan.FromSeconds(30);

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
                    _logger.LogError(ex, "Erro no background worker de notificaÃ§Ãµes.");
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

            List<AppNotification> notifications = await context.Notifications
                .Find(x => !x.Deleted && !x.Send && x.SendAt <= now)
                .ToListAsync();

            if (notifications.Count == 0) return;

            foreach (AppNotification notification in notifications)
            {
                try
                {
                    User? user = await context.Users
                        .Find(x => !x.Deleted && x.Id == notification.UserId)
                        .FirstOrDefaultAsync();

                    string? token = user?.TokenFCM;

                    if (string.IsNullOrWhiteSpace(token))
                    {
                        await MarkAsSentAsync(context, notification.Id);
                        continue;
                    }

                    if (FirebaseAdmin.FirebaseApp.DefaultInstance != null)
                    {
                        var message = new Message
                        {
                            Token = token,
                            Notification = new FirebaseAdmin.Messaging.Notification
                            {
                                Title = notification.Title ?? "",
                                Body = notification.Message ?? ""
                            },
                            Data = new Dictionary<string, string>
                            {
                                { "notificationId", notification.Id ?? "" },
                                { "appointmentId", notification.AppointmentId ?? "" },
                                { "action", notification.Action ?? "" },
                                { "type", notification.Type.ToString() },
                                { "title", notification.Title ?? "" },
                                { "body", notification.Message ?? "" },
                                { "subtitle", notification.Subtitle ?? "" }
                            },
                            Android = new AndroidConfig
                            {
                                Priority = Priority.High,
                                Notification = new AndroidNotification
                                {
                                    Title = notification.Title ?? "",
                                    Body = notification.Message ?? "",
                                    ChannelId = "high_importance_channel",
                                    Sound = "default"
                                }
                            },
                            Apns = new ApnsConfig
                            {
                                Aps = new Aps
                                {
                                    Sound = "default",
                                    ContentAvailable = true
                                }
                            }
                        };

                        await FirebaseMessaging.DefaultInstance.SendAsync(message);
                        _logger.LogInformation("Notificação push FCM enviada para usuário {UserId}: {Title}", notification.UserId, notification.Title);
                    }

                    await MarkAsSentAsync(context, notification.Id!);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Falha ao enviar notificaÃ§Ã£o {Id} para o usuÃ¡rio {UserId}", notification.Id, notification.UserId);
                    await MarkAsSentAsync(context, notification.Id!);
                }
            }
        }

        private async Task MarkAsSentAsync(AppDbContext context, string notificationId)
        {
            var update = Builders<AppNotification>.Update
                .Set(x => x.Send, true)
                .Set(x => x.UpdatedAt, DateTime.UtcNow);

            await context.Notifications.UpdateOneAsync(x => x.Id == notificationId, update);
        }
    }
}



