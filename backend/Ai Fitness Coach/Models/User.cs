using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
namespace Ai_Fitness_Coach.Models
{
    public class User
    {
        [MaxLength(100)]
        public string? Username { get; set; }
        [Key]
        public int Id { get; set; }
        [Required]
        [EmailAddress]
        [MaxLength(255)]
        public string Email { get; set; } = string.Empty;
        [Required]
        public string PasswordHash { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public double? Height { get; set; }
        [Column(TypeName = "decimal(18, 2)")]
        public decimal? Weight { get; set; }
        public int? Age { get; set; }
        [MaxLength(50)]
        public string? Gender { get; set; } = string.Empty;
        public string? RefreshToken { get; set; }
        public DateTime? RefreshTokenExpiryTime { get; set; }
        public bool IsEmailVerified { get; set; } = false;
        public string? VerificationOtp { get; set; }
        public DateTime? VerificationOtpExpiry { get; set; }

        public string? PasswordResetOtp { get; set; }
        public DateTime? PasswordResetOtpExpiry { get; set; }
        [Column(TypeName = "nvarchar(50)")]
        public string? Goal { get; set; }
        public ICollection<WorkoutSession> WorkoutSessions { get; set; } = new HashSet<WorkoutSession>();
        public ICollection<ExerciseAnalysis> ExerciseAnalyses { get; set; } = new HashSet<ExerciseAnalysis>();
    }
}