using Microsoft.AspNetCore.SignalR;

namespace api_bora_trampar.src.SignalR
{
    public class AppointmentHub : Hub
    {
        public async Task JoinAppointmentGroup(string appointmentId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"appointment-{appointmentId}");
        }
    }
}