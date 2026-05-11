using System.ComponentModel.DataAnnotations;

namespace Ai_Fitness_Coach.DTOs
{
    public class ResendOtpRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
    }
}
