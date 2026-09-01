using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Interfaces
{
    public interface IDocumentService
    {
        Task<ResponseApi<List<dynamic>>> GetAllAsync();
        Task<ResponseApi<Document?>> GetByIdAsync(string id);
        Task<ResponseApi<Document?>> CreateAsync(CreateDocumentRequest request);
        Task<ResponseApi<Document?>> UpdateAsync(UpdateDocumentRequest request);
        Task<ResponseApi<Document?>> DeleteAsync(DeleteRequest request);
    }
}
