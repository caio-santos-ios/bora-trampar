using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Utils;
using MongoDB.Bson;

namespace api_bora_trampar.src.Services
{
    public class PaymentService(IPaymentRepository repository) : IPaymentService
    {
        #region READ
        public async Task<ResponseApi<List<dynamic>>> GetAllAsync()
        {
            try
            {
                List<BsonDocument> pipeline =
                [
                    new("$match", new BsonDocument
                    {
                        {"deleted", false},
                    }),
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", new BsonDocument("$toString", "$_id")},
                        {"method_payment", 1},
                        {"date", 1},
                        {"value", 1},
                        {"createdAt", 1}
                    }),
                    new("$sort", new BsonDocument { { "createdAt", -1 } } )
                ];

                List<dynamic> payments = await repository.GetAllAsync(pipeline);

                return new(payments, 200, "Pagamentos listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Payment?>> GetByIdAsync(string id)
        {
            try
            {
                Payment? payment = await repository.GetByIdAsync(id);
                if (payment is null) return new(null, 404, "Pagamento não encontrado");

                return new(payment, 200, "Pagamento buscado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region CREATE
        public async Task<ResponseApi<Payment?>> CreateAsync(CreatePaymentRequest request)
        {
            try
            {
                Payment entity = ObjectMapper.Map<CreatePaymentRequest, Payment>(request);

                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;
                Payment? payment = await repository.CreateAsync(entity);
                if (payment is null) return new(null, 400, "Falha ao criar pagamento");

                return new(payment, 201, "Pagamento criado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region UPDATE
        public async Task<ResponseApi<Payment?>> UpdateAsync(UpdatePaymentRequest request)
        {
            try
            {
                Payment entity = ObjectMapper.Map<UpdatePaymentRequest, Payment>(request);

                entity.UpdatedAt = DateTime.UtcNow;
                Payment? payment = await repository.UpdateAsync(entity);
                if (payment is null) return new(null, 400, "Falha ao atualizar pagamento");

                return new(payment, 200, "Pagamento atualizado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region DELETE
        public async Task<ResponseApi<Payment?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                Payment? existedPayment = await repository.GetByIdAsync(request.Id);
                if (existedPayment is null) return new(null, 404, "Pagamento não encontrado");

                existedPayment.Deleted = true;
                existedPayment.DeletedAt = DateTime.UtcNow;
                existedPayment.DeletedBy = request.DeletedBy;

                Payment payment = await repository.DeleteAsync(existedPayment);
                if (payment is null) return new(null, 400, "Falha ao excluir pagamento");

                return new(payment, 204, "Pagamento excluído com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
    }
}
