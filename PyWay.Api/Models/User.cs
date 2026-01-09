using System.ComponentModel.DataAnnotations.Schema;

namespace PyWay.Api.Models
{
    public class User
    {
        public int Id { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string Role { get; set; } = "User"; 
        public int LeagueId { get; set; } = 1; // По умолчанию 1 (Бронза)
        public League? League { get; set; }
        public DateTime? LastActivityDate { get; set; }
        public int FreezeCount { get; set; } = 0;
        
        // Геймификация
        public int TotalXP { get; set; }
        public int Hearts { get; set; }
        public int CurrentStreak { get; set; }
        public DateTime? LastLoginDate { get; set; }
    }
}