namespace Ai_Fitness_Coach.DTOs
{
    public class UserProfileRequest
    {
        public string Email { get; set; } = string.Empty;
        public string? Username { get; set; }
        public string? Goal { get; set; }
        public int? Age { get; set; }
        public double? Height { get; set; }
        public decimal? Weight { get; set; }
        public string? Gender { get; set; }
    }
}
