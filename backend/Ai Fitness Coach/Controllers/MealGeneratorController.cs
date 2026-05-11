using Ai_Fitness_Coach.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Ai_Fitness_Coach.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MealGeneratorController : ControllerBase
    {
        private readonly IMealService _mealService;

        public MealGeneratorController(IMealService mealService)
        {
            _mealService = mealService;
        }

        private int GetUserId()
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(userIdStr, out int userId) ? userId : 0;
        }

        [HttpGet("generate-plan")]
        public async Task<IActionResult> GetPlan()
        {
            var userId = GetUserId();
            if (userId == 0) return Unauthorized();

            try
            {
                var plan = await _mealService.GenerateFullDayMealPlanAsync(userId);
                return Ok(plan);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }
    }
}
