# Sample Configurations

This directory contains sample configuration files for different AI providers. Copy the appropriate one to your config directory and modify as needed.

## Configuration File Location

The config file should be placed at:
- **Linux**: `~/.config/kok/config.json`
- **macOS**: `~/Library/Application Support/kok/config.json`
- **Windows**: `%APPDATA%\kok\config.json`

## Available Configurations
### For Local Models (Gemma-3-270m)
```bash
mkdir -p ~/.config/kok
echo '{
  "type": "LlamaCpp",
  "model": "unsloth/gemma-3-270m-it-GGUF",
  "contextSize": 2048,
  "temperature": 0.1,
  "maxTokens": 150,
  "port": 8081
}' > ~/.config/kok/config.json
```
### OpenAI (Cloud)
```json
{
  "type": "OpenAI",
  "apiKey": "sk-your_openai_api_key",
  "model": "gpt-4o"
}
```

### Claude (Cloud)
```json
{
  "type": "Claude",
  "apiKey": "your-anthropic-api-key",
  "model": "claude-3-5-sonnet-20241022"
}
```

### Gemini (Cloud)
```json
{
  "type": "Gemini",
  "apiKey": "your-google-api-key",
  "model": "gemini-1.5-pro"
}
```

### Local Models (LlamaCpp)

#### Gemma-3-4B (Recommended)
```json
{
  "type": "LlamaCpp",
  "model": "gemma-3-4b",
  "contextSize": 2048,
  "temperature": 0.1,
  "maxTokens": 150,
  "port": 8080
}
```

#### TinyLlama (Fastest)
```json
{
  "type": "LlamaCpp",
  "model": "tinyllama-1.1b",
  "contextSize": 2048,
  "temperature": 0.1,
  "maxTokens": 150,
  "port": 8080
}
```

#### SmolLM3 (Balanced)
```json
{
  "type": "LlamaCpp",
  "model": "smollm3-3b",
  "contextSize": 4096,
  "temperature": 0.7,
  "maxTokens": 200,
  "port": 8080
}
```

### Custom/Ollama
```json
{
  "type": "Custom",
  "model": "llama3.1",
  "baseURL": "http://localhost:11434/v1",
  "apiKey": "ollama"
}
```

## Quick Setup Commands

### For OpenAI
```bash
mkdir -p ~/.config/kok
echo '{
  "type": "OpenAI",
  "apiKey": "your-api-key-here",
  "model": "gpt-4o"
}' > ~/.config/kok/config.json
```

### For Local Models (Gemma-3-4B)
```bash
mkdir -p ~/.config/kok
echo '{
  "type": "LlamaCpp",
  "model": "gemma-3-4b",
  "contextSize": 2048,
  "temperature": 0.1,
  "maxTokens": 150,
  "port": 8080
}' > ~/.config/kok/config.json
```

## Environment Variables

You can also use environment variables instead of storing API keys in the config file:

```bash
export OPENAI_API_KEY="your-openai-key"
export ANTHROPIC_API_KEY="your-claude-key"
export GOOGLE_API_KEY="your-gemini-key"
export LLAMA_DIR="/path/to/llama.cpp"
```

## Testing Configuration

After setting up your config, test it with:
```bash
kok "echo hello world"
```