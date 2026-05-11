using System.ComponentModel.DataAnnotations;

namespace Ai_Fitness_Coach.DTOs
{
    public class RegisterRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
        [Required]
        [MinLength(6)]
        public string Password { get; set; } = string.Empty;
        [MaxLength(100)]
        public string? Username { get; set; }

        [MaxLength(50)]
        public string? Goal { get; set; }
        public double? Height { get; set; }
        public decimal? Weight { get; set; }
        public int? Age { get; set; }
        public string? Gender { get; set; }
    }
}
