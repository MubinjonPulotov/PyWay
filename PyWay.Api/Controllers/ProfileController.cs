using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore; // Важно для Include
using PyWay.Api.Models;

namespace PyWay.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProfileController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ProfileController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("me")]
        [Authorize]
        public async Task<IActionResult> GetMyProfile()
        {
            var userIdStr = User.FindFirst("id")?.Value;
            if (userIdStr == null) return Unauthorized();
            int userId = int.Parse(userIdStr);

            var user = await _context.Users
                .Include(u => u.League)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null) return NotFound("Истифодабаранда ёфт нашуд");

            // СЧИТАЕМ РЕАЛЬНЫЕ КУРСЫ
            // Ищем количество уникальных CourseId в таблице прогресса этого пользователя
            var startedCoursesCount = await _context.UserProgress
                .Where(p => p.UserId == userId)
                .Include(p => p.Lesson)
                .ThenInclude(l => l.Module)
                .Select(p => p.Lesson.Module.CourseId) // Берем ID курса каждого пройденного урока
                .Distinct() // Оставляем только уникальные
                .CountAsync();

            var response = new
            {
                Username = user.Username,
                Email = user.Email,
                TotalXP = user.TotalXP,
                Hearts = user.Hearts,
                Streak = user.CurrentStreak,
                CoursesCount = startedCoursesCount, // Отправляем реальное число
                League = new 
                {
                    Name = user.League != null ? user.League.Name : "Бронза",
                    Icon = user.League?.IconUrl
                }
            };

            return Ok(response);
        }
    }
}