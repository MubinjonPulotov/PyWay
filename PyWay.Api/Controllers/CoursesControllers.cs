using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PyWay.Api.Models;

namespace PyWay.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CoursesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CoursesController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/courses
        // Этот метод вернет список курсов вместе с модулями
        [HttpGet]
        public async Task<ActionResult<List<Course>>> GetCourses()
        {
            var courses = await _context.Courses
                // .Include говорит базе: "Подгрузи мне еще и связанные Модули"
                .Include(c => c.Modules.OrderBy(m => m.OrderIndex)) 
                .Where(c => c.IsPublished) // Только опубликованные
                .OrderBy(c => c.OrderIndex)
                .ToListAsync();

            return Ok(courses);
        }

        // GET: api/courses/module/5
        // Этот метод вернет конкретный модуль и список его уроков
        [HttpGet("module/{moduleId}")]
        public async Task<ActionResult<Module>> GetModuleDetails(int moduleId)
        {
            var module = await _context.Modules
                .Include(m => m.Lessons.OrderBy(l => l.OrderIndex)) // Подгружаем уроки
                .FirstOrDefaultAsync(m => m.Id == moduleId);

            if (module == null)
            {
                return NotFound(new { message = "Модул ёфт нашуд" });
            }

            return Ok(module);
        }
    }
}