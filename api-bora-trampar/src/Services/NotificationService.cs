using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Requests.Notification;

namespace api_bora_trampar.src.Services
{
    public class NotificationService(INotificationRepository repository) : INotificationService
    {
        public async Task<ResponseApi<List<dynamic>>> GetAllByUserIdAsync(string userId)
        {
            try
            {
                var list = await repository.GetAllByUserIdAsync(userId);
                return new(list, 200, "Notificações listadas com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Erro ao listar notificações - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Notification?>> GetByIdAsync(string id)
        {
            try
            {
                var item = await repository.GetByIdAsync(id);
                if (item == null) return new(null, 404, "Notificação não encontrada");
                return new(item, 200, "Buscado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Erro ao buscar notificação - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Notification>> CreateAsync(CreateNotificationRequest request)
        {
            try
            {
                Notification entity = new()
                {
                    UserId = request.UserId,
                    Title = request.Title,
                    Message = request.Message,
                    Type = request.Type,
                    Read = request.Read,
                    Send = request.Send,
                    SendAt = request.SendAt,
                    CreatedAt = DateTime.UtcNow
                };

                var created = await repository.CreateAsync(entity);
                return new(created, 201, "Notificação criada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Erro ao criar notificação - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Notification?>> MarkAsReadAsync(string id)
        {
            try
            {
                var existed = await repository.GetByIdAsync(id);
                if (existed == null) return new(null, 404, "Notificação não encontrada");

                existed.Read = true;
                existed.UpdatedAt = DateTime.UtcNow;

                var updated = await repository.UpdateAsync(existed);
                return new(updated, 200, "Notificação marcada como lida");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Erro ao atualizar notificação - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Notification?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                var existed = await repository.GetByIdAsync(request.Id);
                if (existed == null) return new(null, 404, "Notificação não encontrada");

                existed.Deleted = true;
                existed.DeletedAt = DateTime.UtcNow;
                existed.DeletedBy = request.DeletedBy;

                var deleted = await repository.DeleteAsync(existed);
                return new(deleted, 200, "Notificação excluída com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Erro ao excluir notificação - {ex.Message}");
            }
        }
    }
}

