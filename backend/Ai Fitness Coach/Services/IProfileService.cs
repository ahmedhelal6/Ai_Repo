using Ai_Fitness_Coach.DTOs;
using System.Threading.Tasks;

namespace Ai_Fitness_Coach.Services
{
    public interface IProfileService
    {
        Task<UserProfileRequest?> GetProfileAsync(int userId);
        Task<bool> EditProfileAsync(int userId, UpdateProfileRequest request);
        Task<bool> LogoutAsync(int userId);
    }
}