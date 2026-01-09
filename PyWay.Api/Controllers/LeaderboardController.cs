using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore; // <--- БЕЗ ЭТОГО INCLUDE НЕ РАБОТАЕТ
using PyWay.Api.Models;

namespace PyWay.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class LeaderboardController : ControllerBase
    {
        private readonly AppDbContext _context;

        public LeaderboardController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("top")]
        public async Task<IActionResult> GetTopUsers()
        {
            // Теперь, когда в User.cs есть public League? League, эта строка сработает
            var topUsers = await _context.Users
                .Include(u => u.League) 
                .OrderByDescending(u => u.TotalXP)
                .Take(10)
                .Select(u => new 
                {
                    u.Id,
                    u.Username,
                    u.TotalXP,
                    // Если лиги нет (null), пишем "Бронза"
                    LeagueName = u.League != null ? u.League.Name : "Бронза"
                })
                .ToListAsync();

            return Ok(topUsers);
        }
    }
}