using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
namespace Ai_Fitness_Coach.Models
{
    public class WorkoutAnalysis
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public int SessionId { get; set; }
        [ForeignKey("SessionId")]
        public WorkoutSession WorkoutSession { get; set; } = null!;
        public double TotalVolume { get; set; }

        public int TotalReps { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
