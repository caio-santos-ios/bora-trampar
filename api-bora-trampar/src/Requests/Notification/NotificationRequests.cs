using api_bora_trampar.src.Models.Enums;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests.Notification
{
    public class CreateNotificationRequest : RequestBase
    {
        public string UserId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public NotificationTypeEnum Type { get; set; } = NotificationTypeEnum.General;
        public bool Read { get; set; } = false;
        public bool Send { get; set; } = false;
        public DateTime SendAt { get; set; } = DateTime.UtcNow;
    }

    public class UpdateNotificationRequest : RequestBase
    {
        public string Id { get; set; } = string.Empty;
        public bool Read { get; set; } = true;
    }
}
