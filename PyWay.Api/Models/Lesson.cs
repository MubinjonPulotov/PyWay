using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace PyWay.Api.Models
{
    public class Lesson
    {
        public int Id { get; set; }
        public int ModuleId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string LessonType { get; set; } = "Theory"; // Theory, Quiz, Code
        public int XPReward { get; set; }
        public int OrderIndex { get; set; }

        // В базе это JSONB, но в C# пока считаем строкой. 
        // PostgreSQL драйвер сам умеет маппить это, но для начала сделаем так:
        [Column(TypeName = "jsonb")]
        public string ContentData { get; set; } = "{}";

        [JsonIgnore]
        public Module? Module { get; set; }
    }
    
}