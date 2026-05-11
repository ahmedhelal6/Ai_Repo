using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Ai_Fitness_Coach.Models
{
    public class WorkoutPlan
    {
        [Key]
        public int Id { get; set; }
        [Required, MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Required]
        public int UserId { get; set; }
        [ForeignKey("UserId")]
        public User User { get; set; } = null!;

        // Join table to link Exercises to this Plan
        public ICollection<WorkoutPlanExercise> PlanExercises { get; set; } = new HashSet<WorkoutPlanExercise>();

        // Sessions that were generated from this plan
        public ICollection<WorkoutSession> Sessions { get; set; } = new HashSet<WorkoutSession>();
    }
}
