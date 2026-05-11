namespace Ai_Fitness_Coach.DTOs
{
    public class ChatMessageDto
    {
        public string Role { get; set; } = string.Empty;// "user" or "assistant"
        public string Content { get; set; } = string.Empty;
    }
}
