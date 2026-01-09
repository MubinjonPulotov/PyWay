using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PyWay.Api.Models;

namespace PyWay.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ShopController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ShopController(AppDbContext context)
        {
            _context = context;
        }

        // Модель запроса на покупку
        public class BuyRequest
        {
            public string ItemId { get; set; } // "heart_refill" или "streak_freeze"
        }

        [HttpPost("buy")]
        [Authorize]
        public async Task<IActionResult> BuyItem([FromBody] BuyRequest request)
        {
            var userIdStr = User.FindFirst("id")?.Value;
            if (userIdStr == null) return Unauthorized();
            int userId = int.Parse(userIdStr);

            var user = await _context.Users.FindAsync(userId);
            if (user == null) return NotFound("Истифодабаранда ёфт нашуд");

            // ЛОГИКА МАГАЗИНА
            if (request.ItemId == "heart_refill")
            {
                int price = 50;
                
                if (user.Hearts >= 5) 
                    return BadRequest("Шумо аллакай ҳаёти пурра доред!");
                
                if (user.TotalXP < price) 
                    return BadRequest("XP кофӣ нест! Бисёр омӯзед.");

                // Покупаем
                user.TotalXP -= price;
                user.Hearts = 5; // Восстанавливаем полностью
            }
            else if (request.ItemId == "streak_freeze")
            {
                int price = 200;

                if (user.FreezeCount >= 2)
                    return BadRequest("Шумо метавонед то 2 яхкунак дошта бошед.");

                if (user.TotalXP < price)
                    return BadRequest("XP кофӣ нест!");

                // Покупаем
                user.TotalXP -= price;
                user.FreezeCount++;
            }
            else
            {
                return BadRequest("Маҳсулот ёфт нашуд!");
            }

            await _context.SaveChangesAsync();

            // Возвращаем обновленный баланс
            return Ok(new 
            { 
                message = "Харид бомуваффақият анҷом ёфт!", 
                newXP = user.TotalXP,
                hearts = user.Hearts,
                freezes = user.FreezeCount
            });
        }
    }
}