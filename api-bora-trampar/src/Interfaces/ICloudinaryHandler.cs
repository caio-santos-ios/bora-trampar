namespace api_bora_trampar.src.Interfaces
{
    public interface ICloudinaryHandler
    {
        Task<string> UploadImageAsync(IFormFile file, string folder = "boratrampar/documents");
        Task<string> UploadVideoAsync(IFormFile file, string folder = "boratrampar/contestations");
        Task<string> UploadBase64Async(string base64Data, string folder = "boratrampar/documents");
        Task<bool> DeleteAsync(string publicId);
    }
}
