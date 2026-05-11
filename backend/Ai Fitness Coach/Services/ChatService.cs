using Ai_Fitness_Coach.DTOs;
using Ai_Fitness_Coach.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Text;

namespace Ai_Fitness_Coach.Services
{
    public class ChatService : IChatService
    {
        private readonly HttpClient _http;
        private readonly string _apiKey;
        private readonly IWorkoutService _workoutService;

        public ChatService(HttpClient http, IConfiguration config, IWorkoutService workoutService)
        {
            _http = http;
            _apiKey = config["Groq:ApiKey"];
            _workoutService = workoutService;

            if (string.IsNullOrEmpty(_apiKey))
                throw new Exception("Groq API Key is missing in appsettings.json");
        }

        public async Task<string> SendMessageAsync(int userId, User user, List<ChatMessageDto> history)
        {
            // 1. Fetch workout plans
            var plans = await _workoutService.GetMyWorkoutsAsync(userId);

            // 2. Fetch progress
            var progress = await _workoutService.GetProgressOverviewAsync(userId);

            // 3. Build plans summary
            var plansSummary = plans.Any()
                ? string.Join("\n", plans.Select(p =>
                    $"- Plan: '{p.Name}' with exercises: " +
                    string.Join(", ", p.Exercises?.Select(e => e.Name) ?? new List<string>())))
                : "No workout plans created yet.";

            // 4. Build progress summary
            var progressSummary = $@"
- Total Volume Lifted: {progress.TotalVolume}kg
- Overall Completion Rate: {progress.OverallCompletion:F1}%
- Sessions This Week: {progress.SessionsThisWeek}
- Weekly Volume: {progress.WeeklyVolume}kg
- Avg Session Volume: {progress.AvgSessionVolume:F1}kg
- Top Exercise by Volume: {progress.TopVolumeExercise}
- Top Workout Plan: {progress.TopWorkout}
- Saved Workout Plans: {progress.SavedWorkouts}";

            // 5. Build the rich system prompt
            var systemPrompt = $@"You are an expert AI fitness coach inside the 'AI Fitness Coach' app.

=== USER PROFILE ===
Name: {user.Username ?? "the user"}
Age: {user.Age?.ToString() ?? "unknown"}
Gender: {user.Gender ?? "unknown"}
Weight: {user.Weight?.ToString() ?? "unknown"}kg
Height: {user.Height?.ToString() ?? "unknown"}cm
Goal: {user.Goal ?? "general fitness"}

=== CURRENT WORKOUT PLANS ===
{plansSummary}

=== PROGRESS STATS ===
{progressSummary}

=== YOUR ROLE ===
- You have full knowledge of this user's plans and progress above.
- Give advice tailored specifically to their data (e.g. if their top exercise is Bench Press, factor that in).
- If they have no plans yet, encourage them to create one in the app.
- Answer fitness, nutrition, and wellness questions only.
- Be encouraging, concise, and practical.
- If asked something unrelated to fitness/health, politely redirect.";

            // 6. Build messages array
            var messages = new List<object>
            {
                new { role = "system", content = systemPrompt }
            };

            foreach (var msg in history)
                messages.Add(new { role = msg.Role, content = msg.Content });

            // 7. Call Groq 
            var requestBody = new
            {
                model = "llama-3.3-70b-versatile",
                messages,
                temperature = 0.7
            };

            var request = new HttpRequestMessage(
                HttpMethod.Post,
                "https://api.groq.com/openai/v1/chat/completions"
            );

            request.Headers.Add("Authorization", $"Bearer {_apiKey}");
            request.Content = new StringContent(
                JsonConvert.SerializeObject(requestBody),
                Encoding.UTF8,
                "application/json"
            );

            var response = await _http.SendAsync(request);
            var responseString = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
                throw new Exception($"Groq API Error: {responseString}");

            var json = JObject.Parse(responseString);
            var reply = json["choices"]?[0]?["message"]?["content"]?.ToString();

            if (string.IsNullOrWhiteSpace(reply))
                throw new Exception("Empty response from Groq");

            return reply;
        }
    }
}