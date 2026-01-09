namespace PyWay.Api.Models
{
    public class League
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty; // Название (Бронза, Серебро...)
        public int MinXP { get; set; }      // Сколько нужно XP для входа
        public string? IconUrl { get; set; } // Ссылка на иконку
    }
}