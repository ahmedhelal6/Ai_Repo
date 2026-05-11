namespace Ai_Fitness_Coach.DTOs
{
    public class CreateWorkoutPlanRequest
    {
        public string? Name { get; set; }
        public List<int>? ExerciseIds { get; set; }
    }
}
