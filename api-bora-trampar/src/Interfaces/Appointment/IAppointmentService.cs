using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Interfaces
{
    public interface IAppointmentService
    {
        Task<ResponseApi<List<dynamic>>> GetAllAsync();
        Task<ResponseApi<Appointment?>> GetByIdAsync(string id);
        Task<ResponseApi<Appointment?>> CreateAsync(CreateAppointmentRequest request);
        Task<ResponseApi<Appointment?>> UpdateAsync(UpdateAppointmentRequest request);
        Task<ResponseApi<Appointment?>> DeleteAsync(DeleteRequest request);
    }
}
