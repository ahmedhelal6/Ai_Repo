using Ai_Fitness_Coach.Data;
using Ai_Fitness_Coach.DTOs;
using Ai_Fitness_Coach.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Ai_Fitness_Coach.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ChatController : ControllerBase
    {
        private readonly IChatService _chatService;
        private readonly ApplicationDbContext _context;

        public ChatController(IChatService chatService, ApplicationDbContext context)
        {
            _chatService = chatService;
            _context = context;
        }

        // POST: api/chat
        [HttpPost]
        public async Task<IActionResult> Chat([FromBody] ChatRequest request)
        {
            try
            {
                var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userIdClaim))
                    return Unauthorized("User ID not found in token.");

                var userId = int.Parse(userIdClaim);
                var user = await _context.Users.FindAsync(userId);

                if (user == null)
                    return NotFound("User not found.");

                var reply = await _chatService.SendMessageAsync(userId, user, request.Messages);

                return Ok(new { reply });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = ex.Message,
                    inner = ex.InnerException?.Message
                });
            }
        }
    }
}