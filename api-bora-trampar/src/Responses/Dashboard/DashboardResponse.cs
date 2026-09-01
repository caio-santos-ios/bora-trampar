namespace api_bora_trampar.src.Responses.Dashboard
{
    public class DashboardResponse
    {
        public decimal TotalRevenue { get; set; } = 0;
        public int MonthAppointments { get; set; } = 0;
        public int ActivePros { get; set; } = 0;
        public int PendingVerifications { get; set; } = 0;
        public int OpenDisputes { get; set; } = 0;
        public double SatisfactionRate { get; set; } = 100.0;

        public List<RevenueHistoryItem> RevenueHistory { get; set; } = [];
        public List<CategoryDistributionItem> CategoryDistribution { get; set; } = [];
        public List<RecentAppointmentItem> RecentAppointments { get; set; } = [];
    }

    public class RevenueHistoryItem
    {
        public string Label { get; set; } = string.Empty;
        public decimal Revenue { get; set; } = 0;
    }

    public class CategoryDistributionItem
    {
        public string Name { get; set; } = string.Empty;
        public int Count { get; set; } = 0;
    }

    public class RecentAppointmentItem
    {
        public string Id { get; set; } = string.Empty;
        public string Customer { get; set; } = string.Empty;
        public string Professional { get; set; } = string.Empty;
        public string Service { get; set; } = string.Empty;
        public string Date { get; set; } = string.Empty;
        public decimal Value { get; set; } = 0;
        public string Status { get; set; } = "confirmed";
        public string StatusText { get; set; } = "Confirmado";
    }
}
