using System.Text.Json.Serialization;

namespace PyWay.Api.Models
{
    public class UserProgress
    {
        public int UserId { get; set; }
        public int LessonId { get; set; }
        
        public bool IsCompleted { get; set; }
        public DateTime CompletedAt { get; set; } = DateTime.UtcNow;
        public string? UserSubmission { get; set; } // Сохраненный ответ

        // Связи (чтобы можно было легко достать данные юзера или урока)
        [JsonIgnore]
        public User? User { get; set; }
        [JsonIgnore]
        public Lesson? Lesson { get; set; }
    }
}