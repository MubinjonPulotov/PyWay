namespace PyWay.Api.Services
{
    // То, что мы отправляем
    public class PistonRequest
    {
        public string Language { get; set; } = "python";
        public string Version { get; set; } = "3.10.0";
        public List<PistonFile> Files { get; set; } = new();
    }

    public class PistonFile
    {
        public string Content { get; set; } = string.Empty;
    }

    // То, что мы получаем в ответ
    public class PistonResponse
    {
        public PistonRunResult Run { get; set; } = new();
    }

    public class PistonRunResult
    {
        public string Stdout { get; set; } = string.Empty; // Обычный вывод
        public string Stderr { get; set; } = string.Empty; // Ошибки
        public string Output { get; set; } = string.Empty; // Всё вместе
        public int Code { get; set; } // 0 = успех, 1 = ошибка
    }
}