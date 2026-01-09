using System.Text;
using System.Text.Json;

namespace PyWay.Api.Services
{
    public class CodeRunnerService
    {
        private readonly HttpClient _httpClient;

        public CodeRunnerService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<string> ExecutePython(string code)
        {
            // 1. Готовим посылку
            var requestData = new PistonRequest
            {
                Language = "python",
                Version = "3.10.0",
                Files = new List<PistonFile> 
                { 
                    new PistonFile { Content = code } 
                }
            };

            // Превращаем в JSON
            var jsonContent = new StringContent(
                JsonSerializer.Serialize(requestData, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase }),
                Encoding.UTF8,
                "application/json");

            // 2. Отправляем запрос на сервер Piston (это публичный API)
            var response = await _httpClient.PostAsync("https://emkc.org/api/v2/piston/execute", jsonContent);

            if (!response.IsSuccessStatusCode)
            {
                return "Error: External API unavailable";
            }

            // 3. Читаем ответ
            var responseString = await response.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<PistonResponse>(responseString, 
                new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });

            // Возвращаем только текст вывода (output)
            return result?.Run.Output ?? "";
        }
    }
}