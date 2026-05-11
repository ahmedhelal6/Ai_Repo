using System.ComponentModel.DataAnnotations;

namespace Ai_Fitness_Coach.DTOs
{
    public class RefreshTokenRequest
    {
        [Required]
        public string AccessToken { get; set; } = string.Empty;
        [Required]
        public string RefreshToken { get; set; } = string.Empty;
    }
}