using System.Text.Json.Serialization;

namespace PyWay.Api.Models
{
    public class Module
    {
        public int Id { get; set; }
        public int CourseId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public int OrderIndex { get; set; }

        // Игнорируем циклическую ссылку при отправке JSON на клиент
        [JsonIgnore] 
        public Course? Course { get; set; }
        
        public List<Lesson> Lessons { get; set; } = new();
    }
}