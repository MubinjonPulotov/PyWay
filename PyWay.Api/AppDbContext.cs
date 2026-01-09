using Microsoft.EntityFrameworkCore;
using PyWay.Api.Models;

namespace PyWay.Api
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Course> Courses { get; set; }
        public DbSet<Module> Modules { get; set; }
        public DbSet<Lesson> Lessons { get; set; }
        public DbSet<League> Leagues { get; set; } // Если есть класс Leagues
        public DbSet<UserProgress> UserProgress { get; set; }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // 2. ВАЖНО: Настраиваем составной ключ (UserId + LessonId)
            modelBuilder.Entity<UserProgress>()
                .HasKey(up => new { up.UserId, up.LessonId });
            // Говорим C#, что таблицы в базе называются именно так (с учетом регистра или без)
            // Но для PostgreSQL лучше всего принудительно использовать нижний регистр для таблиц
            modelBuilder.Entity<User>().ToTable("users");
            modelBuilder.Entity<Course>().ToTable("courses");
            modelBuilder.Entity<Module>().ToTable("modules");
            modelBuilder.Entity<Lesson>().ToTable("lessons");
            modelBuilder.Entity<League>().ToTable("leagues"); // Если есть класс Leagues
            modelBuilder.Entity<UserProgress>().ToTable("userprogress");
            foreach (var entity in modelBuilder.Model.GetEntityTypes())
            {
                foreach (var property in entity.GetProperties())
                {
                    // Например: C# свойство "Title" -> в базе ищем "title"
                    property.SetColumnName(property.Name.ToLower());
                }
            }
        }
    }
}