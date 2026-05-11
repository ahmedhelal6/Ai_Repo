namespace Ai_Fitness_Coach.DTOs
{
    public class MealPlanResponseDto
    {
        public double TotalCalories { get; set; }
        public double Protein { get; set; }
        public double Carbs { get; set; }
        public double Fats { get; set; }
        public List<MealDto> Meals { get; set; } = new();
    }
}
