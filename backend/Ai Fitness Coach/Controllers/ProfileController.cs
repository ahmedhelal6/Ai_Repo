using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Ai_Fitness_Coach.DTOs;
using Ai_Fitness_Coach.Services;
using System.Threading.Tasks;

namespace Ai_Fitness_Coach.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Requires a valid JWT token
    public class ProfileController : ControllerBase
    {
        private readonly IProfileService _profileService;

        public ProfileController(IProfileService profileService)
        {
            _profileService = profileService;
        }

        // Helper method to keep endpoints clean
        private int GetUserId()
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(userIdStr, out int userId) ? userId : 0;
        }

        // GET: api/profile
        [HttpGet]
        public async Task<IActionResult> GetProfile()
        {
            var userId = GetUserId();
            if (userId == 0) return Unauthorized();

            var profile = await _profileService.GetProfileAsync(userId);
            if (profile == null) return NotFound(new { message = "User not found." });

            return Ok(profile);
        }

        // PUT: api/profile/edit
        [HttpPut("edit")]
        public async Task<IActionResult> EditProfile([FromBody] UpdateProfileRequest request)
        {
            var userId = GetUserId();
            if (userId == 0) return Unauthorized();

            var success = await _profileService.EditProfileAsync(userId, request);
            if (!success) return NotFound(new { message = "User not found." });

            return Ok(new { message = "Profile updated successfully." });
        }

        // POST: api/profile/logout
        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            var userId = GetUserId();
            if (userId == 0) return Unauthorized();

            var success = await _profileService.LogoutAsync(userId);
            if (!success) return NotFound(new { message = "User not found." });

            return Ok(new { message = "Logged out successfully." });
        }
    }
}