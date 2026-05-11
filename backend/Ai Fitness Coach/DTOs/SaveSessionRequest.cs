namespace Ai_Fitness_Coach.DTOs
{
    public class SaveSessionRequest
    {
        public int WorkoutPlanId { get; set; }
        public List<ExerciseSessionUpdateDto>? Exercises { get; set; }
    }
}
