using Ai_Fitness_Coach.DTOs;

namespace Ai_Fitness_Coach.Services
{
    public interface IWorkoutService
    {
        Task<WorkoutPlanDto> CreateWorkoutPlanAsync(int userId, CreateWorkoutPlanRequest request);
        Task<List<WorkoutPlanDto>> GetMyWorkoutsAsync(int userId);
        Task<WorkoutSessionDto> SaveWorkoutSessionAsync(int userId, SaveSessionRequest request);
        Task<Dictionary<string, List<ExerciseDto>>> GetAllExercisesAsync();
        Task<ProgressOverviewDto> GetProgressOverviewAsync(int userId);
        Task<bool> DeleteWorkoutPlanAsync(int planId, int userId);
    }
}
