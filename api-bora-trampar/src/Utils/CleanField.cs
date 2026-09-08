namespace api_bora_trampar.src.Utils
{
    public static class CleanField
    {
        public static string CleanDocument(string document)
        {
            return document.Replace(".", "").Replace("-", "");
        }
        public static string CleanPhone(string document)
        {
            return document.Replace("(", "").Replace(")", "");
        }
    }
}