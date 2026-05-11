namespace Ai_Fitness_Coach.DTOs
{
    public class ExerciseSessionUpdateDto
    {
        public int ExerciseId { get; set; }
        public List<WorkoutSetDto>? Sets { get; set; }
    }
}
