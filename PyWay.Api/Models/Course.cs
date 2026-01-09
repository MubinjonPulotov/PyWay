namespace PyWay.Api.Models
{
    public class Course
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? IconUrl { get; set; }
        public bool IsPublished { get; set; }
        public int OrderIndex { get; set; }

        // Связь: У курса много модулей
        public List<Module> Modules { get; set; } = new();
    }
}