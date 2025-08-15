# kok

<div align="center">
  <h3>✨ Natural language to shell commands using AI ✨</h3>
  <p>Transform your thoughts into executable shell commands instantly</p>
  
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License">
  <img src="https://img.shields.io/badge/Node.js-18+-green.svg" alt="Node.js">
  <img src="https://img.shields.io/badge/AI-GPT%20%7C%20Claude%20%7C%20Gemini%20%7C%20Local-blue.svg" alt="AI Support">
</div>

## What is kok?

`kok` is a lightweight, focused CLI tool that converts natural language into shell commands using Large Language Models (LLMs). Unlike comprehensive development tools, `kok` has a simple, singular purpose: **helping you write shell commands faster, without switching context**.

Think of it as the terminal equivalent of quickly searching "how do I..." and getting an immediately runnable answer.

### Key Features

- 🤖 **Multiple AI Providers**: OpenAI GPT, Claude, Gemini, and local models via llama.cpp
- ⚡ **Lightning Fast**: Generate commands in seconds
- 🔧 **Interactive Editing**: Review and modify commands before execution
- 🌍 **Cross-Platform**: Works on Linux, macOS, and Windows
- 🔒 **Privacy-Focused**: Local model support for sensitive environments
- 📝 **Context Aware**: Understands your current directory and environment

## Quick Start

### 1. Installation
### Quick Install (Recommended)
```bash
curl -s https://raw.githubusercontent.com/MAXNORM8650/kok/main/install.sh | bash
```
```bash
# if /usr/local/bin is not writable, it installs to ~/.local/bin so
export PATH="$HOME/.local/bin:$PATH"
```
```bash 
# change the config from defalt to local cpp models, eg. 
echo '{
  "type": "LlamaCpp",
  "model": "ggml-org/gemma-3-4b-it-GGUF",
  "contextSize": 2048,
  "temperature": 0.1,
  "maxTokens": 150,
  "port":8081, 
  "threads": 4
}' > ~/.config/kok/config.json
```
```bash
# Finally export the path for llama.cpp if it is alredy installed else install from https://github.com/ggml-org/llama.cpp 
export LLAMA_DIR=path/to/llama.cpp
```
### Build from github source
```bash
# Clone the repository
git clone https://github.com/MAXNORM8650/kok.git
cd kok

# Install dependencies (requires Bun)
bun install

# Build the binary
bun run build

# Make executable and install globally
chmod +x dist/kok-cli
sudo mv dist/kok-cli /usr/local/bin/kok-cli
```

### 2. Configuration

On first run, `kok` creates a default configuration file. Choose your preferred AI provider:

#### Option A: OpenAI (Recommended for beginners)
```bash
# Edit your config (auto-created on first run)
kok "test command"  # This creates the config file

# Then edit with your API key:
{
  "type": "OpenAI",
  "apiKey": "sk-your_openai_api_key",
  "model": "gpt-4o"
}
```

#### Option B: Claude
```bash
{
  "type": "Claude",
  "apiKey": "your-anthropic-api-key",
  "model": "claude-3-5-sonnet-20241022"
}
```

#### Option C: Local Models (Privacy-focused)
```bash
# First, install llama.cpp
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
make llama-server

# Set environment variable
export LLAMA_DIR=/path/to/llama.cpp

# Configure kok for local models
{
  "type": "LlamaCpp",
  "model": "gemma-3-4b",
  "contextSize": 2048,
  "temperature": 0.1,
  "maxTokens": 150,
  "port": 8081
}
```

### 3. Shell Integration

Add this function to your `~/.zshrc` or `~/.bashrc`:

```bash
kok() {
  local cmd
  cmd="$(kok-cli "$@")" || return
  echo "Generated: $cmd"
  vared -p "Execute? " -c cmd  # zsh
  # read -e -i "$cmd" -p "Execute? " cmd  # bash
  print -s -- "$cmd"   # add to history
  eval "$cmd"
}

# Helper functions
kok_stop() {
  pkill llama-server && echo "Local AI server stopped"
}

kok_status() {
  echo "🤖 kok Configuration:"
  local config_path=$(kok-cli --config-path 2>/dev/null || echo "~/.config/kok/config.json")
  if [ -f "$config_path" ]; then
    echo "   Provider: $(cat "$config_path" | grep -o '"type":"[^"]*"' | cut -d'"' -f4)"
    echo "   Model: $(cat "$config_path" | grep -o '"model":"[^"]*"' | cut -d'"' -f4)"
  else
    echo "   Status: Not configured"
  fi
}
```

Reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```

## Usage Examples

### Basic Commands
```bash
# File operations
kok "list all files in this directory"
kok "create a new directory called projects"
kok "copy all .txt files to backup folder"

# System information
kok "show disk usage for current directory"
kok "find all processes using port 3000"
kok "check system memory usage"

# Git operations
kok "create a new git branch called feature-auth"
kok "commit all changes with message 'fix bug'"
kok "show git log for the last 5 commits"

# Network operations
kok "download file from url https://example.com/file.zip"
kok "check if port 8081 is open"
kok "ping google with 4 packets"
```

### Advanced Examples
```bash
# Complex file operations
kok "find all JavaScript files modified in the last 7 days and show their sizes"
kok "compress all log files older than 30 days"
kok "create a tar archive of src directory excluding node_modules"

# System administration
kok "create a new user account with sudo privileges"
kok "setup a cron job to backup database daily at 2am"
kok "check which service is listening on port 443"

# Development tasks
kok "start a local web server on port 8000"
kok "generate ssh key for github and add to agent"
kok "set environment variable NODE_ENV to production"
```

## Configuration Guide

### Provider Types

#### 1. OpenAI
```json
{
  "type": "OpenAI",
  "apiKey": "sk-your_openai_api_key",
  "model": "gpt-4o"
}
```

#### 2. Claude
```json
{
  "type": "Claude",
  "apiKey": "your-anthropic-api-key",
  "model": "claude-3-5-sonnet-20241022"
}
```

#### 3. Google Gemini
```json
{
  "type": "Gemini",
  "apiKey": "your-google-api-key",
  "model": "gemini-1.5-pro"
}
```

#### 4. Custom/Local (Ollama, etc.)
```json
{
  "type": "Custom",
  "model": "llama3.1",
  "baseURL": "http://localhost:11434/v1",
  "apiKey": "ollama"
}
```

#### 5. LlamaCpp (Local models)
```json
{
  "type": "LlamaCpp",
  "model": "gemma-3-4b",
  "contextSize": 2048,
  "temperature": 0.1,
  "maxTokens": 150,
  "port": 8081
}
```

### Supported Local Models

| Model | Size | Speed | Quality | Use Case |
|-------|------|-------|---------|----------|
| `tinyllama-1.1b` | 1.1B | ⚡⚡⚡ | ⭐⭐ | Basic commands, fast responses |
| `smollm3-3b` | 3B | ⚡⚡ | ⭐⭐⭐ | Good balance of speed/quality |
| `gemma-3-4b` | 4B | ⚡ | ⭐⭐⭐⭐ | Recommended for most users |
| `llama-3.2-3b` | 3B | ⚡⚡ | ⭐⭐⭐⭐ | Good quality, efficient |

### Configuration File Location

The config file is automatically created at:
- **Linux**: `~/.config/kok/config.json`
- **macOS**: `~/Library/Application Support/kok/config.json`
- **Windows**: `%APPDATA%\kok\config.json`

## Local Models Setup (LlamaCpp)

### Prerequisites
```bash
# Install llama.cpp
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
mkdir -p build
cd build
cmake ..
cmake --build . --config Release
# Set environment variable
export LLAMA_DIR=/path/to/llama.cpp
echo 'export LLAMA_DIR=/path/to/llama.cpp' >> ~/.zshrc
```

### Quick Model Configuration
```bash
# Gemma-3-4B (Recommended)
echo '{
  "type": "LlamaCpp",
  "model": "bartowski/google_gemma-3n-E4B-it-GGUF",
  "contextSize": 2048,
  "temperature": 0.1,
  "maxTokens": 150,
  "port": 8081,
  "threads": 4
}' > ~/.config/kok/config.json
# Gemma-3-270m (fast but not good)
echo '{
  "type": "LlamaCpp",
  "model": "unsloth/gemma-3-270m-it-GGUF",
  "contextSize": 2048,
  "temperature": 0.1,
  "maxTokens": 150,
  "port": 8081,
  "threads": 8
}' > ~/.config/kok/config.json

# TinyLlama (Fastest)
echo '{"type":"LlamaCpp","model":"tinyllama-1.1b","contextSize":2048,"temperature":0.1,"maxTokens":150,"port":8081}' > ~/.config/kok/config.json

# SmolLM3-3B (Balanced)
echo '{"type":"LlamaCpp","model":"ggml-org/SmolLM3-3B-GGUF","contextSize":2048,"temperature":0.1,"maxTokens":150,"port":8081, "threads": 4}' > ~/.config/kok/config.json
```

### How It Works
- **First Use**: Downloads model from Hugging Face (one-time setup)
- **Background Server**: Starts llama-server automatically
- **Persistent**: Server runs in background for fast subsequent requests
- **Memory Efficient**: Only loads model once, reuses for multiple queries

## Troubleshooting

### Common Issues

#### "No command generated"
- Check your API key configuration
- Verify internet connection (for cloud providers)
- Try a simpler command description

#### "LLAMA_DIR not set" (Local models)
```bash
# Make sure llama.cpp is installed and built
export LLAMA_DIR=/path/to/your/llama.cpp
```

#### "Server won't start" (Local models)
```bash
# Check if port is available
netstat -tulpn | grep 8081

# Or change port in config
{
  "type": "LlamaCpp",
  "model": "gemma-3-4b",
  "port": 8081
}
```

#### "API key not found"
- Check config file exists and has valid JSON
- For OpenAI: Set `OPENAI_API_KEY` environment variable
- Verify API key format and permissions

### Getting Help

```bash
# Check current configuration
kok_status

# Test basic functionality
kok "echo hello world"

# Stop local AI server
kok_stop
```

## Advanced Usage

### Environment Variables
```bash
export OPENAI_API_KEY="your-key"        # OpenAI API key
export ANTHROPIC_API_KEY="your-key"     # Claude API key
export GOOGLE_API_KEY="your-key"        # Gemini API key
export LLAMA_DIR="/path/to/llama.cpp"   # Local models
export KOK_CONFIG="/custom/config.json" # Custom config path
```

### Scripting with kok

```bash
#!/bin/bash
# Example: Automated backup script using kok

# Generate backup command
BACKUP_CMD=$(kok-cli "create tar archive of home directory excluding .cache and .tmp")

# Review and execute
echo "Generated command: $BACKUP_CMD"
read -p "Execute? (y/n): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    eval "$BACKUP_CMD"
fi
```

### Performance Tuning

For local models, adjust these parameters in your config:

```json
{
  "type": "LlamaCpp",
  "model": "bartowski/google_gemma-3n-E4B-it-GGUF",
  "contextSize": 4096,     # Larger for complex commands
  "temperature": 0.0,      # More deterministic (0.0-1.0)
  "maxTokens": 200,        # Longer commands
  "threads": 8             # Use more CPU cores
}
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Bun](https://bun.sh) for fast TypeScript execution
- Inspired by natural language interfaces for command-line tools
- Thanks to the open-source AI community for model development

---

<div align="center">
  <p>Made with ❤️ for developers who think in natural language</p>
  <p>⭐ Star this repo if kok helps you write better shell commands!</p>
</div>
