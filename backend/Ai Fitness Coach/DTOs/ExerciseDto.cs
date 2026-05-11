namespace Ai_Fitness_Coach.DTOs
{
    public class ExerciseDto
    {
        public int? ExerciseId { get; set; }
        public string? Name { get; set; }
        public List<string>? TargetMuscles { get; set; }
        public List<string>? Equipments { get; set; }
        public string? ImageUrl { get; set; }
        public string? VideoUrl { get; set; }
        public string? ExerciseType { get; set; }
    }
}
