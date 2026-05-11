using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Ai_Fitness_Coach.Models
{
    public class WorkoutPlanExercise
    {
        [Key]
        public int Id { get; set; }

        public int WorkoutPlanId { get; set; }
        [ForeignKey("WorkoutPlanId")]
        public WorkoutPlan WorkoutPlan { get; set; } = null!;

        public int ExerciseId { get; set; }
        [ForeignKey("ExerciseId")]
        public Exercise Exercise { get; set; } = null!;
    }
}
