using Ai_Fitness_Coach.Models;
using Ai_Fitness_Coach.DTOs;
using Ai_Fitness_Coach.Data;
using System.Threading.Tasks;

namespace Ai_Fitness_Coach.Services
{
    public class ProfileService : IProfileService
    {
        private readonly ApplicationDbContext _context;

        public ProfileService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<UserProfileRequest?> GetProfileAsync(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return null;

            return new UserProfileRequest
            {
                Email = user.Email,
                Username = user.Username,
                Goal = user.Goal,
                Age = user.Age,
                Height = user.Height,
                Weight = user.Weight,
                Gender = user.Gender
            };
        }

        public async Task<bool> EditProfileAsync(int userId, UpdateProfileRequest request)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return false;

            // Update only the provided fields
            if (!string.IsNullOrWhiteSpace(request.Username)) user.Username = request.Username;
            if (!string.IsNullOrWhiteSpace(request.Goal))
                user.Goal = request.Goal;
            if (request.Age.HasValue) user.Age = request.Age.Value;
            if (request.Height.HasValue) user.Height = request.Height.Value;
            if (request.Weight.HasValue) user.Weight = request.Weight.Value;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> LogoutAsync(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return false;

            // Nullify the refresh token to end the session
            user.RefreshToken = null;
            user.RefreshTokenExpiryTime = null;

            await _context.SaveChangesAsync();
            return true;
        }
    }
}