using System.ComponentModel.DataAnnotations;

namespace Ai_Fitness_Coach.DTOs
{
    public class UpdateProfileRequest
    {
        [MaxLength(100)]
        public string? Username { get; set; }

        public string? Goal { get; set; }

        public int? Age { get; set; }
        public double? Height { get; set; }
        public decimal? Weight { get; set; }
    }
}
