namespace Ai_Fitness_Coach.DTOs
{
    public class ChatRequest
    {
        public List<ChatMessageDto> Messages { get; set; } = new();
    }
}
