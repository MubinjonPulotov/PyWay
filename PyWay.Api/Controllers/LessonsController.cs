using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PyWay.Api.Dtos;
using PyWay.Api.Models;
using PyWay.Api.Services;
using System.Text.Json;

namespace PyWay.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class LessonsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly CodeRunnerService _codeRunner;

        public LessonsController(AppDbContext context, CodeRunnerService codeRunner)
        {
            _context = context;
            _codeRunner = codeRunner;
        }

        [HttpPost("complete")]
        [Authorize]
        public async Task<IActionResult> CompleteLesson([FromBody] LessonSubmissionDto request)
        {
            // 1. Получаем пользователя
            var userIdStr = User.FindFirst("id")?.Value;
            if (userIdStr == null) return Unauthorized();
            int userId = int.Parse(userIdStr);

            var user = await _context.Users.FindAsync(userId);
            if (user == null) return NotFound("Истифодабаранда ёфт нашуд");

            // --- МАГИЯ СТРАЙКА И ЖИЗНЕЙ ---
            var today = DateTime.UtcNow.Date;
            var lastActive = user.LastActivityDate?.Date;

            // Если новый день наступил
            if (lastActive != today) 
            {
                // Восстанавливаем жизни до 5 каждый новый день
                if (user.Hearts < 5) user.Hearts = 5;

                // Логика Страйка
                if (lastActive == today.AddDays(-1))
                {
                    // Если был вчера -> увеличиваем страйк
                    user.CurrentStreak++;
                }
                else if (lastActive < today.AddDays(-1))
                {
                    // Если пропустил день -> сброс на 1
                    user.CurrentStreak = 1;
                }
                else 
                {
                    // Если вообще первый раз -> 1
                    if (user.CurrentStreak == 0) user.CurrentStreak = 1;
                }

                user.LastActivityDate = DateTime.UtcNow;
            }
            
            // Проверка: Хватает ли жизней?
            if (user.Hearts <= 0)
            {
                return BadRequest(new 
                { 
                    message = "Ҳаётча ба итмом расид! 💔 Пагоҳ биёед.", 
                    isCorrect = false,
                    hearts = 0
                });
            }

            // 2. Ищем урок
            var lesson = await _context.Lessons.FindAsync(request.LessonId);
            if (lesson == null) return NotFound("Дарс ёфт нашуд");

            // 3. Проверяем ответ
            var checkResult = await CheckAnswer(lesson, request.Submission);

            if (!checkResult.IsCorrect)
            {
                // ОШИБКА -> ОТНИМАЕМ ЖИЗНЬ
                user.Hearts--;
                await _context.SaveChangesAsync(); // Сохраняем потерю жизни

                return BadRequest(new 
                { 
                    message = "Хато", 
                    isCorrect = false,
                    actualOutput = checkResult.ActualOutput,
                    expectedOutput = checkResult.ExpectedOutput,
                    hearts = user.Hearts // Возвращаем остаток жизней
                });
            }

            // УСПЕХ -> Начисляем XP (если проходим впервые)
            var existingProgress = await _context.UserProgress
                .FirstOrDefaultAsync(p => p.UserId == userId && p.LessonId == request.LessonId);

            int xpGained = 0;
            if (existingProgress == null)
            {
                var progress = new UserProgress
                {
                    UserId = userId,
                    LessonId = request.LessonId,
                    IsCompleted = true,
                    UserSubmission = request.Submission,
                    CompletedAt = DateTime.UtcNow
                };
                _context.UserProgress.Add(progress);
                
                user.TotalXP += lesson.XPReward;
                xpGained = lesson.XPReward;
                
                // Проверяем лиги (простая логика)
                if (user.TotalXP > 100) user.LeagueId = 2; // Серебро (нужно создать в БД)
                if (user.TotalXP > 500) user.LeagueId = 3; // Золото
            }
            else
            {
                // Если перепроходим - обновляем решение, но XP не даем
                existingProgress.UserSubmission = request.Submission;
                existingProgress.CompletedAt = DateTime.UtcNow;
            }
            
            // Обновляем дату активности (даже если проходили в тот же день, обновляем время)
            user.LastActivityDate = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return Ok(new 
            { 
                message = "Дарс гузашта шуд!", 
                isCorrect = true, 
                xpGained = xpGained,
                totalXP = user.TotalXP,
                hearts = user.Hearts, // Возвращаем жизни
                output = checkResult.ActualOutput
            });
        }

        // Вспомогательные классы и методы проверки остаются теми же
        private class CheckResult
        {
            public bool IsCorrect { get; set; }
            public string ActualOutput { get; set; } = "";
            public string ExpectedOutput { get; set; } = "";
        }

        private async Task<CheckResult> CheckAnswer(Lesson lesson, string? submission)
        {
            var result = new CheckResult { IsCorrect = false };

            if (lesson.LessonType == "Theory") 
            {
                result.IsCorrect = true;
                return result;
            }

            if (lesson.LessonType == "Quiz")
            {
                using JsonDocument doc = JsonDocument.Parse(lesson.ContentData);
                if (doc.RootElement.TryGetProperty("options", out JsonElement options))
                {
                    foreach (var option in options.EnumerateArray())
                    {
                        if (option.GetProperty("is_correct").GetBoolean())
                        {
                            int correctId = option.GetProperty("id").GetInt32();
                            if (int.TryParse(submission, out int userChoice) && userChoice == correctId)
                            {
                                result.IsCorrect = true;
                            }
                        }
                    }
                }
                return result;
            }

            if (lesson.LessonType == "Code")
            {
                using JsonDocument doc = JsonDocument.Parse(lesson.ContentData);
                string expected = "";
                if (doc.RootElement.TryGetProperty("expected_output", out JsonElement expectedEl))
                {
                    expected = expectedEl.GetString() ?? "";
                }
                result.ExpectedOutput = expected;

                string realOutput = await _codeRunner.ExecutePython(submission ?? "");
                result.ActualOutput = realOutput;

                if (realOutput.Trim() == expected.Trim())
                {
                    result.IsCorrect = true;
                }
            }

            return result;
        }
    }
}