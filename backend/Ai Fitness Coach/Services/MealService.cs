using Ai_Fitness_Coach.Data;
using Ai_Fitness_Coach.DTOs;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Text;

namespace Ai_Fitness_Coach.Services
{
    public class MealService : IMealService
    {
        private readonly HttpClient _http;
        private readonly string _apiKey;
        private readonly ApplicationDbContext _context;

        public MealService(HttpClient http, IConfiguration config, ApplicationDbContext context)
        {
            _http = http;
            _context = context;
            _apiKey = config["Groq:ApiKey"]!;

            if (string.IsNullOrEmpty(_apiKey))
                throw new Exception("Groq API Key is missing in appsettings.json");
        }

        public async Task<MealPlanResponseDto> GenerateFullDayMealPlanAsync(int userId)
        {
            // Fetch the user internally — controller stays clean
            var user = await _context.Users.FindAsync(userId)
                ?? throw new KeyNotFoundException("User not found.");

            // Guard: profile must be complete enough to generate a meaningful plan
            if (user.Weight == null || user.Height == null || user.Age == null || string.IsNullOrWhiteSpace(user.Goal))
                throw new InvalidOperationException("Please complete your profile (weight, height, age, and goal) before generating a meal plan.");

            var prompt = $@"Act as a creative Egyptian nutritionist AI.
User Profile: Gender: {user.Gender}, Age: {user.Age}, Weight: {user.Weight}, Height: {user.Height}, Goal: {user.Goal}.
 
STRICT OUTPUT RULES:
- Return ONLY valid JSON.
- NO markdown formatting (no ```json).
- NO conversational text or explanations.
 
VARIETY & CREATIVITY CONSTRAINTS:
1. RANDOMNESS: Use a completely different set of ingredients compared to typical 'standard' fitness diets.
2. EGYPTIAN AUTHENTICITY: Incorporate diverse items like Molokhia, Musakaa (healthy version), Mahshi (portioned), Koshary (protein-style), Besara, or Feteer Meshaltet (low-fat version).
3. THE 'NO-REPEAT' RULE: You must never suggest the same meal name twice in one plan.
4. EGG LIMIT: Eggs are restricted to a maximum of ONE meal per day.
5. SURPRISE ME: For every request, internally rotate through different protein sources (Calf liver, Rabbit, Shrimp, Nile Perch, Pigeon, or Legumes).
 
OUTPUT SCHEMA:
{{
  ""totalCalories"": number,
  ""protein"": number,
  ""carbs"": number,
  ""fats"": number,
  ""meals"": [
    {{ ""type"": ""Breakfast"", ""name"": ""string"", ""calories"": number }},
    {{ ""type"": ""Snack 1"", ""name"": ""string"", ""calories"": number }},
    {{ ""type"": ""Lunch"", ""name"": ""string"", ""calories"": number }},
    {{ ""type"": ""Snack 2"", ""name"": ""string"", ""calories"": number }},
    {{ ""type"": ""Dinner"", ""name"": ""string"", ""calories"": number }}
  ]
}}
 
FINAL CHECK: Ensure the Egyptian dish names are descriptive (e.g., 'Grilled Kofta with Roasted Eggplant' instead of just 'Kofta').";

            var requestBody = new
            {
                model = "llama-3.3-70b-versatile",
                messages = new[]
                {
                    new { role = "user", content = prompt }
                },
                temperature = 1.2
            };

            var httpRequest = new HttpRequestMessage(
                HttpMethod.Post,
                "https://api.groq.com/openai/v1/chat/completions"
            );

            httpRequest.Headers.Add("Authorization", $"Bearer {_apiKey}");
            httpRequest.Content = new StringContent(
                JsonConvert.SerializeObject(requestBody),
                Encoding.UTF8,
                "application/json"
            );

            var response = await _http.SendAsync(httpRequest);
            var responseString = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
                throw new Exception($"Groq API Error: {responseString}");

            var json = JObject.Parse(responseString);
            var rawText = json["choices"]?[0]?["message"]?["content"]?.ToString();

            if (string.IsNullOrWhiteSpace(rawText))
                throw new Exception("Empty response from Groq.");

            var cleanJson = ExtractJson(rawText);

            try
            {
                return JsonConvert.DeserializeObject<MealPlanResponseDto>(cleanJson)!;
            }
            catch (Exception ex)
            {
                throw new Exception($"JSON Parse Error:\n{cleanJson}", ex);
            }
        }

        private string ExtractJson(string text)
        {
            int start = text.IndexOf('{');
            int end = text.LastIndexOf('}');

            if (start == -1 || end == -1)
                throw new Exception("No JSON found in AI response.");

            return text.Substring(start, end - start + 1);
        }
    }
}

