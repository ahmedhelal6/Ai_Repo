namespace Ai_Fitness_Coach.DTOs
{
    public class WorkoutSessionDto
    {
        public int? Id { get; set; }
        public int?   WorkoutId { get; set; }
        public string? WorkoutName { get; set; }
        public DateTime PerformedAt { get; set; }
        public List<ExerciseSessionDto>? Exercises { get; set; }
        public double TotalVolume { get; set; }
        public double Progress { get; set; }
        public int? UserId { get; set; }
    }
}
