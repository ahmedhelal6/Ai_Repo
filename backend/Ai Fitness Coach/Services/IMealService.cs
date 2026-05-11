using Ai_Fitness_Coach.DTOs;

namespace Ai_Fitness_Coach.Services
{
    public interface IMealService
    {
        Task<MealPlanResponseDto> GenerateFullDayMealPlanAsync(int userId);
    }
}
