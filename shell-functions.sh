#!/bin/bash
# kok - Natural language to shell commands
# Shell integration functions
#
# Usage: Add this to your ~/.zshrc or ~/.bashrc:
#   source /path/to/shell-functions.sh
# Or:
#   curl -s https://raw.githubusercontent.com/your-repo/kok/main/shell-functions.sh >> ~/.zshrc

# Main kok function with interactive editing
kok() {
  local cmd
  
  # Generate command using kok-cli
  cmd="$(kok-cli "$@")" || return 1
  
  if [ -z "$cmd" ]; then
    echo "❌ No command generated"
    return 1
  fi
  
  # Show generated command
  echo "💡 Generated: $cmd"
  
  # Interactive editing (zsh/bash compatible)
  if [ -n "$ZSH_VERSION" ]; then
    # zsh
    vared -p "Execute? (edit/enter to run, ctrl+c to cancel): " cmd
  elif [ -n "$BASH_VERSION" ]; then
    # bash
    read -e -i "$cmd" -p "Execute? (edit/enter to run, ctrl+c to cancel): " cmd
  else
    # fallback for other shells
    echo -n "Execute '$cmd'? (y/n): "
    read -r confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "yes" ]; then
      return 0
    fi
  fi
  
  # Add to history and execute
  if [ -n "$cmd" ]; then
    # Add to shell history
    if [ -n "$ZSH_VERSION" ]; then
      print -s -- "$cmd"
    elif [ -n "$BASH_VERSION" ]; then
      history -s "$cmd"
    fi
    
    # Execute the command
    echo "🚀 Executing: $cmd"
    eval "$cmd"
  fi
}

# Direct execution without editing (use with caution)
kok_direct() {
  local cmd
  cmd="$(kok-cli "$@")" || return 1
  
  if [ -z "$cmd" ]; then
    echo "❌ No command generated"
    return 1
  fi
  
  echo "🚀 Executing: $cmd"
  eval "$cmd"
}

# Stop local AI server (for LlamaCpp users)
kok_stop() {
  if pkill -f llama-server; then
    echo "🛑 Local AI server stopped"
  else
    echo "ℹ️ No local AI server running"
  fi
}

# Show current configuration
kok_status() {
  echo "🤖 kok Status:"
  
  # Check if kok-cli is installed
  if command -v kok-cli >/dev/null 2>&1; then
    echo "   Binary: ✅ Installed at $(which kok-cli)"
  else
    echo "   Binary: ❌ Not found in PATH"
    return 1
  fi
  
  # Find config file
  local config_path=""
  if [ "$(uname)" = "Darwin" ]; then
    config_path="$HOME/Library/Application Support/kok/config.json"
  elif [ "$(uname)" = "Linux" ]; then
    config_path="$HOME/.config/kok/config.json"
  else
    config_path="$HOME/.config/kok/config.json"
  fi
  
  if [ -f "$config_path" ]; then
    echo "   Config: ✅ Found at $config_path"
    
    # Extract provider and model info
    if command -v jq >/dev/null 2>&1; then
      local provider=$(jq -r '.type // "unknown"' "$config_path")
      local model=$(jq -r '.model // "unknown"' "$config_path")
      echo "   Provider: $provider"
      echo "   Model: $model"
    else
      # Fallback without jq
      local provider=$(grep -o '"type":"[^"]*"' "$config_path" | cut -d'"' -f4)
      local model=$(grep -o '"model":"[^"]*"' "$config_path" | cut -d'"' -f4)
      echo "   Provider: ${provider:-unknown}"
      echo "   Model: ${model:-unknown}"
    fi
    
    # Check if LlamaCpp server is running
    if [ "$provider" = "LlamaCpp" ]; then
      local port=$(grep -o '"port":[0-9]*' "$config_path" | cut -d':' -f2)
      port=${port:-8080}
      if curl -s "http://localhost:$port/health" >/dev/null 2>&1; then
        echo "   Server: ✅ Running on port $port"
      else
        echo "   Server: ⏸️ Not running (will start automatically)"
      fi
    fi
  else
    echo "   Config: ❌ Not found at $config_path"
    echo "   Run 'kok --setup' or create config manually"
  fi
}

# Test kok with a simple command
kok_test() {
  echo "🧪 Testing kok with: 'echo hello world'"
  kok_direct "echo hello world"
}

# Quick configuration helpers
kok_config_openai() {
  local config_dir
  if [ "$(uname)" = "Darwin" ]; then
    config_dir="$HOME/Library/Application Support/kok"
  else
    config_dir="$HOME/.config/kok"
  fi
  
  mkdir -p "$config_dir"
  
  echo "🔧 Setting up OpenAI configuration..."
  echo -n "Enter your OpenAI API key: "
  read -r api_key
  
  cat > "$config_dir/config.json" <<EOF
{
  "type": "OpenAI",
  "apiKey": "$api_key",
  "model": "gpt-4o"
}
EOF
  
  echo "✅ OpenAI configuration saved"
  kok_status
}

kok_config_local() {
  local config_dir
  if [ "$(uname)" = "Darwin" ]; then
    config_dir="$HOME/Library/Application Support/kok"
  else
    config_dir="$HOME/.config/kok"
  fi
  
  mkdir -p "$config_dir"
  
  echo "🔧 Setting up local model configuration..."
  echo "Available models:"
  echo "1. gemma-3-4b (Recommended, balanced)"
  echo "2. smollm3-3b (Small, efficient)"
  echo "3. tinyllama-1.1b (Fastest, basic)"
  echo -n "Choose model (1-3): "
  read -r choice
  
  local model
  case $choice in
    1) model="gemma-3-4b" ;;
    2) model="smollm3-3b" ;;
    3) model="tinyllama-1.1b" ;;
    *) model="gemma-3-4b" ;;
  esac
  
  cat > "$config_dir/config.json" <<EOF
{
  "type": "LlamaCpp",
  "model": "$model",
  "contextSize": 2048,
  "temperature": 0.1,
  "maxTokens": 150,
  "port": 8080
}
EOF
  
  echo "✅ Local model configuration saved"
  echo "📋 Make sure to set LLAMA_DIR environment variable:"
  echo "   export LLAMA_DIR=/path/to/llama.cpp"
  kok_status
}

# Help function
kok_help() {
  echo "🚀 kok - Natural language to shell commands"
  echo ""
  echo "Basic usage:"
  echo "  kok 'describe what you want to do'"
  echo ""
  echo "Examples:"
  echo "  kok 'list all files'"
  echo "  kok 'create directory called projects'"
  echo "  kok 'find all .js files modified today'"
  echo ""
  echo "Available functions:"
  echo "  kok           - Interactive command generation"
  echo "  kok_direct    - Direct execution (no editing)"
  echo "  kok_status    - Show configuration status"
  echo "  kok_test      - Test with simple command"
  echo "  kok_stop      - Stop local AI server"
  echo "  kok_help      - Show this help"
  echo ""
  echo "Quick setup:"
  echo "  kok_config_openai  - Configure OpenAI"
  echo "  kok_config_local   - Configure local models"
  echo ""
  echo "For more information: https://github.com/your-repo/kok"
}

# Auto-completion for zsh
if [ -n "$ZSH_VERSION" ]; then
  # Basic completion - can be expanded later
  compdef '_files' kok
fi

# Welcome message (shown once per session)
if [ -z "$KOK_WELCOME_SHOWN" ]; then
  export KOK_WELCOME_SHOWN=1
  if command -v kok-cli >/dev/null 2>&1; then
    echo "🤖 kok functions loaded! Try: kok 'list files' or kok_help"
  fi
fi