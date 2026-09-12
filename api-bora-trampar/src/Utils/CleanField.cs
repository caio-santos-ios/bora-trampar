using System.Text.RegularExpressions;

namespace api_bora_trampar.src.Utils
{
    public static class CleanField
    {
        public static string CleanDocument(string document)
        {
            return document.Replace(".", "").Replace("-", "").Replace("/", "");
        }
        public static string CleanPhone(string document)
        {
            return Regex.Replace(document, @"\D", "");
        }
    }
}