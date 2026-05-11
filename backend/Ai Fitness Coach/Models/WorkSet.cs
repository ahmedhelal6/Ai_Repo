using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Ai_Fitness_Coach.Models
{
    public class WorkoutSet
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public int SetNumber { get; set; }
        [Required]
        public int Reps { get; set; }
        [Column(TypeName = "decimal(18, 2)")]
        public decimal? Weight { get; set; } = null;

        public bool IsCompleted { get; set; } = false;

        [Required]
        public int WorkoutSessionId { get; set; }
        [ForeignKey("WorkoutSessionId")]
        public WorkoutSession WorkoutSession { get; set; } = null!;

        [Required]
        public int ExerciseId { get; set; }
        [ForeignKey("ExerciseId")]
        public Exercise Exercise { get; set; } = null!;
    }
}