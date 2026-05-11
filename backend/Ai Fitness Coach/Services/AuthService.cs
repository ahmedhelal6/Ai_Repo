using Ai_Fitness_Coach.Data;
using Ai_Fitness_Coach.DTOs;
using Ai_Fitness_Coach.Models;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;

namespace Ai_Fitness_Coach.Services
{

    public class AuthService : IAuthService
    {
        private readonly ApplicationDbContext _context;
        private readonly IConfiguration _config;
        private readonly IEmailService _emailService;

        public AuthService(ApplicationDbContext context, IConfiguration config, IEmailService emailService)
        {
            _context = context;
            _config = config;
            _emailService = emailService;
        }

        public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
        {
            await CleanupUnverifiedUsersAsync();
            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
                throw new InvalidOperationException("Email already in use.");
            var otp = GenerateOtp();
            var user = new User
            {
                Email = request.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                Username = request.Username,
                Goal = request.Goal,
                Height = request.Height,
                Weight = request.Weight,
                Age = request.Age,
                Gender = request.Gender,
                IsEmailVerified = false,
                VerificationOtp = otp,
                VerificationOtpExpiry = DateTime.UtcNow.AddMinutes(5)
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();
            await _emailService.SendOtpEmailAsync(user.Email, otp);
            return new AuthResponse
            {
                Email = user.Email,
                Token = "",
                RefreshToken = "",
                ExpiresAt = DateTime.UtcNow
            };
        }

        public async Task<AuthResponse> LoginAsync(LoginRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email)
                ?? throw new UnauthorizedAccessException("Invalid credentials.");

            if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                throw new UnauthorizedAccessException("Invalid credentials.");
            if (!user.IsEmailVerified)
                throw new UnauthorizedAccessException("Please verify your email first.");

            return await GenerateTokensAsync(user);
        }

        // --- NEW: Refresh Token Logic ---
        public async Task<AuthResponse> RefreshTokenAsync(RefreshTokenRequest request)
        {
            // 1. Extract the user from the expired JWT
            var principal = GetPrincipalFromExpiredToken(request.AccessToken);
            if (principal == null)
                throw new UnauthorizedAccessException("Invalid access token.");

            var email = principal.FindFirstValue(ClaimTypes.Email);

            // 2. Find the user in the DB
            var user = await _context.Users.SingleOrDefaultAsync(u => u.Email == email);
            if (user == null || user.RefreshToken != request.RefreshToken || user.RefreshTokenExpiryTime <= DateTime.UtcNow)
            {
                throw new UnauthorizedAccessException("Invalid or expired refresh token.");
            }

            // 3. Generate new tokens
            return await GenerateTokensAsync(user);
        }
        public async Task<AuthResponse> VerifyOtpAsync(VerifyOtpRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email)
                ?? throw new UnauthorizedAccessException("Invalid email.");

            if (user.IsEmailVerified)
                throw new InvalidOperationException("Email already verified.");

            if (user.VerificationOtp != request.Code ||
                user.VerificationOtpExpiry < DateTime.UtcNow)
            {
                throw new UnauthorizedAccessException("Invalid or expired OTP.");
            }

            user.IsEmailVerified = true;
            user.VerificationOtp = null;
            user.VerificationOtpExpiry = null;

            _context.Users.Update(user);
            await _context.SaveChangesAsync();

            //Now generate tokens
            return await GenerateTokensAsync(user);
        }
        public async Task ForgotPasswordAsync(ForgotPasswordRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email)
                ?? throw new UnauthorizedAccessException("User not found.");

            var otp = GenerateOtp();

            user.PasswordResetOtp = otp;
            user.PasswordResetOtpExpiry = DateTime.UtcNow.AddMinutes(5);

            _context.Users.Update(user);
            await _context.SaveChangesAsync();

            //  Send OTP
            await _emailService.SendOtpEmailAsync(user.Email, otp);
        }
        public async Task ResetPasswordAsync(ResetPasswordRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email)
                ?? throw new UnauthorizedAccessException("User not found.");

            if (user.PasswordResetOtp != request.Otp ||
                user.PasswordResetOtpExpiry < DateTime.UtcNow)
            {
                throw new UnauthorizedAccessException("Invalid or expired OTP.");
            }

            //  Update password
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);

            //  Clear OTP
            user.PasswordResetOtp = null;
            user.PasswordResetOtpExpiry = null;

            _context.Users.Update(user);
            await _context.SaveChangesAsync();
        }
        // Generates BOTH the short-lived JWT and the long-lived Refresh Token
        private async Task<AuthResponse> GenerateTokensAsync(User user)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            // JWT now expires in 15 minutes!
            var expires = DateTime.UtcNow.AddMinutes(15);

            var claims = new[]
            {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
        };

            var token = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: expires,
                signingCredentials: creds
            );

            var accessToken = new JwtSecurityTokenHandler().WriteToken(token);
            var refreshToken = GenerateRefreshToken();

            // Save the new refresh token to the database
            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7); // Refresh token lasts 7 days

            _context.Users.Update(user);
            await _context.SaveChangesAsync();

            return new AuthResponse
            {
                UserId = user.Id,
                Token = accessToken,
                RefreshToken = refreshToken,
                Email = user.Email,
                ExpiresAt = expires
            };
        }

        // Creates a cryptographically secure random string
        private string GenerateRefreshToken()
        {
            var randomNumber = new byte[64];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }

        // Reads the claims from an expired JWT without failing validation
        private ClaimsPrincipal? GetPrincipalFromExpiredToken(string token)
        {
            var tokenValidationParameters = new TokenValidationParameters
            {
                ValidateAudience = true,
                ValidateIssuer = true,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!)),
                ValidIssuer = _config["Jwt:Issuer"],
                ValidAudience = _config["Jwt:Audience"],
                ValidateLifetime = false // CRITICAL: We ignore expiration here because we expect it to be expired!
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out SecurityToken securityToken);

            var jwtSecurityToken = securityToken as JwtSecurityToken;
            if (jwtSecurityToken == null || !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase))
                throw new SecurityTokenException("Invalid token");

            return principal;
        }
        private async Task CleanupUnverifiedUsersAsync()
        {
            var expiryTime = DateTime.UtcNow.AddMinutes(-30); // 30 min expiry

            var unverifiedUsers = await _context.Users
                .Where(u => !u.IsEmailVerified && u.CreatedAt < expiryTime)
                .ToListAsync();

            if (unverifiedUsers.Any())
            {
                _context.Users.RemoveRange(unverifiedUsers);
                await _context.SaveChangesAsync();
            }
        }
        public async Task ResendOtpAsync(ResendOtpRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email)
                ?? throw new Exception("User not found");

            if (user.IsEmailVerified)
                throw new Exception("Email already verified");

            var otp = GenerateOtp();

            user.VerificationOtp = otp;
            user.VerificationOtpExpiry = DateTime.UtcNow.AddMinutes(5);

            _context.Users.Update(user);
            await _context.SaveChangesAsync();

            await _emailService.SendOtpEmailAsync(user.Email, otp);
        }
        private string GenerateOtp()
        {
            var random = new Random();
            return random.Next(100000, 999999).ToString();
        }
    }
}
