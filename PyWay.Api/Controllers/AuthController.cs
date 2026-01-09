using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PyWay.Api.Dtos;
using PyWay.Api.Models;
using BCrypt.Net;
using System.Security.Claims;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.IdentityModel.Tokens.Jwt;

namespace PyWay.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration; // Читалка настроек

        public AuthController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<ActionResult<User>> Register(RegisterDto request)
        {
            if (await _context.Users.AnyAsync(u => u.Username == request.Username))
            {
                return BadRequest("Истифодабаранда аллакай вуҷуд дорад.");
            }

            string passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

            var user = new User
            {
                Username = request.Username,
                Email = request.Email,
                PasswordHash = passwordHash,
                Role = "User",
                Hearts = 5,
                TotalXP = 0,
                LeagueId = 1,
                LastLoginDate = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Бақайдгирӣ муваффақ!" });
        }

        // НОВЫЙ МЕТОД: ВХОД
        [HttpPost("login")]
        public async Task<ActionResult<string>> Login(LoginDto request)
        {
            // 1. Ищем пользователя
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == request.Username);
            
            // 2. Если пользователя нет
            if (user == null)
            {
                return BadRequest("Истифодабаранда ёфт нашуд.");
            }

            // 3. Проверяем пароль (сравниваем то, что ввел, с хэшем в базе)
            if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            {
                return BadRequest("Пароли хато.");
            }

            // 4. Если всё ок — выдаем Токен
            string token = CreateToken(user);
            
            return Ok(new { token = token, userId = user.Id, username = user.Username, role = user.Role });
        }

        // ВСПОМОГАТЕЛЬНЫЙ МЕТОД: ГЕНЕРАЦИЯ ТОКЕНА
        private string CreateToken(User user)
        {
            List<Claim> claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Role, user.Role),
                new Claim("id", user.Id.ToString()) // Зашиваем ID пользователя внутрь токена
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JwtSettings:SecretKey"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.Now.AddDays(30), // Токен живет 30 дней
                signingCredentials: creds
            );

            var jwt = new JwtSecurityTokenHandler().WriteToken(token);
            return jwt;
        }
    }
}