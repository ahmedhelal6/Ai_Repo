using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Ai_Fitness_Coach.Models
{
    public class WorkoutSession
    {
        [Key]
        public int Id { get; set; }

        public int? WorkoutPlanId { get; set; }
        [ForeignKey("WorkoutPlanId")]
        public WorkoutPlan? WorkoutPlan { get; set; }

        [Required]
        public int UserId { get; set; }
        [ForeignKey("UserId")]
        public User User { get; set; } = null!;

        public bool IsCompleted { get; set; } = false;
        [Required]
        public DateTime StartTime { get; set; } = DateTime.UtcNow;
        public ICollection<WorkoutSet> WorkoutSets { get; set; } = new HashSet<WorkoutSet>();
        public WorkoutAnalysis? WorkoutAnalysis { get; set; }
        public ICollection<ExerciseAnalysis> ExerciseAnalyses { get; set; } = new HashSet<ExerciseAnalysis>();
    }
}
