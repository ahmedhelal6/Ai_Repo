using Ai_Fitness_Coach.Models;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class ExerciseAnalysis
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int UserId { get; set; }
    [ForeignKey("UserId")]
    public User User { get; set; } = null!;

    [Required]
    public int ExerciseId { get; set; }
    [ForeignKey("ExerciseId")]
    public Exercise Exercise { get; set; } = null!;

    public int? WorkoutSessionId { get; set; }
    [ForeignKey("WorkoutSessionId")]
    public WorkoutSession? WorkoutSession { get; set; }
    [Range(0, 100)]
    public double FormScore { get; set; }

    public int RepsDetected { get; set; }

    public string Feedback { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}