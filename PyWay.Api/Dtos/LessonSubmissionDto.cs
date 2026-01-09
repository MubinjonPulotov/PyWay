namespace PyWay.Api.Dtos
{
    public class LessonSubmissionDto
    {
        public int LessonId { get; set; }
        
        // Для теста это ID ответа (например, "2").
        // Для кода это сам код (например, "print('hello')").
        // Для теории можно оставить пустым.
        public string? Submission { get; set; } 
    }
}