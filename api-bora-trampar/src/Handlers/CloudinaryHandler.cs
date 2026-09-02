using api_bora_trampar.src.Interfaces;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;

namespace api_bora_trampar.src.Handlers
{
    public class CloudinaryHandler : ICloudinaryHandler
    {
        private readonly Cloudinary? _cloudinary;

        public CloudinaryHandler()
        {
            string cloudName = Environment.GetEnvironmentVariable("CLOUDINARY_CLOUD_NAME") ?? "";
            string apiKey = Environment.GetEnvironmentVariable("CLOUDINARY_API_KEY") ?? "";
            string apiSecret = Environment.GetEnvironmentVariable("CLOUDINARY_API_SECRET") ?? "";
            string cloudinaryUrl = Environment.GetEnvironmentVariable("CLOUDINARY_URL") ?? "";

            if (!string.IsNullOrEmpty(cloudinaryUrl))
            {
                _cloudinary = new Cloudinary(cloudinaryUrl);
                _cloudinary.Api.Secure = true;
            }
            else if (!string.IsNullOrEmpty(cloudName) && !string.IsNullOrEmpty(apiKey) && !string.IsNullOrEmpty(apiSecret))
            {
                var account = new Account(cloudName, apiKey, apiSecret);
                _cloudinary = new Cloudinary(account);
                _cloudinary.Api.Secure = true;
            }
        }

        public async Task<string> UploadImageAsync(IFormFile file, string folder = "boratrampar/documents")
        {
            try
            {
                if (_cloudinary == null)
                {
                    using var ms = new MemoryStream();
                    await file.CopyToAsync(ms);
                    var bytes = ms.ToArray();
                    var base64 = Convert.ToBase64String(bytes);
                    return $"data:{file.ContentType};base64,{base64}";
                }

                string extension = Path.GetExtension(file.FileName).ToLower();
                string fileName = Guid.NewGuid().ToString();

                using var memoryStream = new MemoryStream();
                await file.CopyToAsync(memoryStream);
                memoryStream.Position = 0;

                var uploadParams = new ImageUploadParams
                {
                    File = new FileDescription(fileName + extension, memoryStream),
                    Folder = folder,
                    PublicId = fileName,
                    Overwrite = true
                };

                var result = await _cloudinary.UploadAsync(uploadParams);
                return result.SecureUrl?.ToString() ?? result.Url?.ToString() ?? "";
            }
            catch
            {
                using var ms = new MemoryStream();
                await file.CopyToAsync(ms);
                var bytes = ms.ToArray();
                var base64 = Convert.ToBase64String(bytes);
                return $"data:{file.ContentType};base64,{base64}";
            }
        }

        public async Task<string> UploadBase64Async(string base64Data, string folder = "boratrampar/documents")
        {
            try
            {
                if (_cloudinary == null)
                {
                    return base64Data;
                }

                string fileName = Guid.NewGuid().ToString();

                var uploadParams = new ImageUploadParams
                {
                    File = new FileDescription(fileName, base64Data),
                    Folder = folder,
                    PublicId = fileName,
                    Overwrite = true
                };

                var result = await _cloudinary.UploadAsync(uploadParams);
                return result.SecureUrl?.ToString() ?? result.Url?.ToString() ?? base64Data;
            }
            catch
            {
                return base64Data;
            }
        }

        public async Task<bool> DeleteAsync(string publicId)
        {
            if (_cloudinary == null || string.IsNullOrWhiteSpace(publicId)) return false;

            var deletionParams = new DeletionParams(publicId);
            var result = await _cloudinary.DestroyAsync(deletionParams);

            return result.Result == "ok";
        }
    }
}
