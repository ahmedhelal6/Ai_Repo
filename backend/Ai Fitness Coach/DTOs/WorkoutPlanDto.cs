namespace Ai_Fitness_Coach.DTOs
{
    public class WorkoutPlanDto
    {
        public int? Id { get; set; } 
        public string? Name { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<ExerciseSessionDto>? Exercises { get; set; }
        public double Progress { get; set; }
        public int SessionsCount { get; set; }
        public int? UserId { get; set; }
    }
}
