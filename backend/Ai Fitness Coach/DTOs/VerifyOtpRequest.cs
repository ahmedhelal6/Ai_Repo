using System.ComponentModel.DataAnnotations;

namespace Ai_Fitness_Coach.DTOs
{
    public class VerifyOtpRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string Code { get; set; } = string.Empty;
    }
}
