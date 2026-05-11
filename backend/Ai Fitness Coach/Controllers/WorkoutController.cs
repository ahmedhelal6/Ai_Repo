using Ai_Fitness_Coach.DTOs;
using Ai_Fitness_Coach.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Ai_Fitness_Coach.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] // Assuming you have JWT set up
    public class WorkoutController : ControllerBase
    {
        private readonly IWorkoutService _workoutService;

        public WorkoutController(IWorkoutService workoutService)
        {
            _workoutService = workoutService;
        }

        // POST: api/workout/plan (Pics 1, 2, 3)
        [HttpPost("plan")]
        public async Task<IActionResult> CreatePlan([FromBody] CreateWorkoutPlanRequest request)
        {
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));
            var result = await _workoutService.CreateWorkoutPlanAsync(userId, request);
            return Ok(result);
        }

        // GET: api/workout/plans (Pic 4)
        [HttpGet("plans")]
        public async Task<IActionResult> GetMyPlans()
        {
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));
            var result = await _workoutService.GetMyWorkoutsAsync(userId);
            return Ok(result);
        }

        // POST: api/workout/session (Pic 5 - pressing SAVE)
        [HttpPost("session")]
        public async Task<IActionResult> SaveSession([FromBody] SaveSessionRequest request)
        {
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));
            var result = await _workoutService.SaveWorkoutSessionAsync(userId, request);
            return Ok(result);
        }
        [HttpGet("exercises")]
        [AllowAnonymous] // Usually, you want users to see exercises even before logging in
        public async Task<IActionResult> GetAllExercises()
        {
            try
            {
                var exercises = await _workoutService.GetAllExercisesAsync();
                return Ok(exercises);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }
        [HttpGet("progress")]
        public async Task<IActionResult> GetProgressOverview()
        {
            try
            {
                var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userIdClaim)) return Unauthorized("User ID not found in token.");

                var userId = int.Parse(userIdClaim);
                var result = await _workoutService.GetProgressOverviewAsync(userId);

                return Ok(result);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching progress: {ex.Message}");
                return StatusCode(500, "Internal server error calculating progress.");
            }
        }
        [HttpDelete("plan/{planId}")]
        public async Task<IActionResult> DeleteWorkoutPlan(int planId)
        {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdClaim)) return Unauthorized("User ID not found in token.");
            var userId = int.Parse(userIdClaim);

            var success = await _workoutService.DeleteWorkoutPlanAsync(planId, userId);

            if (!success)
            {
                return NotFound(new { message = "Workout plan not found or you do not have permission to delete it." });
            }

            return Ok(new { message = "Workout plan deleted successfully." });
        }
    }
}
