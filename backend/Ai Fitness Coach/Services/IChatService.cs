using Ai_Fitness_Coach.DTOs;
using Ai_Fitness_Coach.Models;

namespace Ai_Fitness_Coach.Services
{
    public interface IChatService
    {
        Task<string> SendMessageAsync(int userId, User user, List<ChatMessageDto> history);
    }
}