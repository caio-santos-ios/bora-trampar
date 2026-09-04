using System.Text.Json.Serialization;
using api_bora_trampar.src.Models.Base;

namespace api_bora_trampar.src.Models._Base
{
    public class PaginationApi<TData> : ResponseApi<TData>
    {
        [JsonConstructor]
        public PaginationApi(
            TData? data,
            long totalCount,
            int currentPage = 1,
            int pageSize = 20)
            : base(data)
        {
            Data = data;
            TotalCount = totalCount;
            CurrentPage = currentPage;
            PageSize = pageSize;
        }

        public PaginationApi(
            TData? data,
            int code = 200,
            string? message = null)
            : base(data, code, message)
        {
        }

        public int PageSize { get; set; } = 20;
        public int TotalPages => (int)Math.Ceiling(TotalCount / (double)PageSize);
        public int CurrentPage { get; set; }
        public long TotalCount { get; set; }

        [JsonIgnore]
        public override dynamic Result => new
        {
            TotalCount,
            CurrentPage,
            PageSize,
            TotalPages,
            Data
        };
    }
}