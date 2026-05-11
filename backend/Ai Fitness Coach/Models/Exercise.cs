using Ai_Fitness_Coach.Models;
using System.ComponentModel.DataAnnotations;
namespace Ai_Fitness_Coach.Models
{
    public class Exercise
    {
        [Key]
        public int Id { get; set; }
        [Required, MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        [Required, MaxLength(255)]
        public string TargetMuscles { get; set; } = string.Empty;
        [MaxLength(255)]
        public string Equipment { get; set; } = string.Empty;

        [Required, MaxLength(100)]
        public string ExerciseType { get; set; } = string.Empty;

        public string? ImageUrl { get; set; }
        public string? VideoUrl { get; set; }
        public bool IsDeleted { get; set; } = false;

        public ICollection<WorkoutSet> WorkoutSets { get; set; } = new HashSet<WorkoutSet>();
        public ICollection<ExerciseAnalysis> ExerciseAnalyses { get; set; } = new HashSet<ExerciseAnalysis>();
    }
}