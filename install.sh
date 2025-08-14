#!/bin/bash
# kok - Natural language to shell commands
# Installation script
#
# Usage:
#   curl -s https://raw.githubusercontent.com/your-repo/kok/main/install.sh | bash
#   or
#   wget -qO- https://raw.githubusercontent.com/your-repo/kok/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

title() {
    echo -e "${PURPLE}$1${NC}"
}

# Detect OS and architecture
detect_os() {
    case "$(uname -s)" in
        Linux*)     OS=linux;;
        Darwin*)    OS=macos;;
        CYGWIN*)    OS=windows;;
        MINGW*)     OS=windows;;
        *)          OS=unknown;;
    esac
    
    case "$(uname -m)" in
        x86_64)     ARCH=x64;;
        arm64)      ARCH=arm64;;
        aarch64)    ARCH=arm64;;
        armv7l)     ARCH=arm;;
        *)          ARCH=unknown;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Bun if not present
install_bun() {
    if command_exists bun; then
        log "Bun already installed: $(bun --version)"
        return 0
    fi
    
    log "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    
    # Add to PATH for current session
    export PATH="$HOME/.bun/bin:$PATH"
    
    if command_exists bun; then
        log "Bun installed successfully: $(bun --version)"
    else
        error "Failed to install Bun"
        return 1
    fi
}

# Create directories
create_directories() {
    log "Creating directories..."
    
    # Config directory
    case $OS in
        macos)
            CONFIG_DIR="$HOME/Library/Application Support/kok"
            ;;
        *)
            CONFIG_DIR="$HOME/.config/kok"
            ;;
    esac
    
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$HOME/.local/bin"
    
    log "Config directory: $CONFIG_DIR"
}

# Download and build kok
install_kok() {
    log "Installing kok..."
    
    # Temporary directory for build
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Clone repository
    if command_exists git; then
        log "Cloning repository..."
        git clone https://github.com/your-repo/kok.git .
    else
        # Fallback: download zip
        log "Downloading source..."
        curl -L https://github.com/your-repo/kok/archive/main.zip -o kok.zip
        unzip kok.zip
        cd kok-main
    fi
    
    # Install dependencies and build
    log "Building kok..."
    bun install
    bun run build
    
    # Install binary
    if [ -w "/usr/local/bin" ]; then
        cp dist/kok-cli /usr/local/bin/kok-cli
        chmod +x /usr/local/bin/kok-cli
        log "Installed kok-cli to /usr/local/bin"
    else
        warn "/usr/local/bin is not writable, installing to ~/.local/bin"
        cp dist/kok-cli "$HOME/.local/bin/kok-cli"
        chmod +x "$HOME/.local/bin/kok-cli"
        
        # Add to PATH if not already there
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc" 2>/dev/null || true
            warn "Added ~/.local/bin to PATH in shell configs"
        fi
    fi
    
    # Cleanup
    cd "$HOME"
    rm -rf "$TEMP_DIR"
}

# Install shell functions
install_shell_functions() {
    log "Installing shell functions..."
    
    # Download shell functions
    curl -s https://raw.githubusercontent.com/your-repo/kok/main/shell-functions.sh > /tmp/kok-functions.sh
    
    # Add to shell configs
    for shell_config in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if [ -f "$shell_config" ]; then
            if ! grep -q "kok-functions.sh" "$shell_config" 2>/dev/null; then
                echo "" >> "$shell_config"
                echo "# kok - Natural language to shell commands" >> "$shell_config"
                echo "source /tmp/kok-functions.sh" >> "$shell_config"
                log "Added kok functions to $shell_config"
            fi
        fi
    done
    
    # Make functions available in current session
    source /tmp/kok-functions.sh 2>/dev/null || true
}

# Interactive configuration
configure_kok() {
    log "Starting configuration..."
    
    title "Choose your AI provider:"
    echo "1. OpenAI (GPT-4, requires API key)"
    echo "2. Claude (Anthropic, requires API key)"
    echo "3. Local models (no API key needed, requires setup)"
    echo "4. Skip configuration (configure later)"
    
    echo -n "Enter your choice (1-4): "
    read -r choice
    
    case $choice in
        1)
            configure_openai
            ;;
        2)
            configure_claude
            ;;
        3)
            configure_local
            ;;
        4)
            log "Skipped configuration. Run 'kok_status' to configure later."
            ;;
        *)
            warn "Invalid choice. Skipping configuration."
            ;;
    esac
}

configure_openai() {
    echo -n "Enter your OpenAI API key: "
    read -r api_key
    
    cat > "$CONFIG_DIR/config.json" <<EOF
{
  "type": "OpenAI",
  "apiKey": "$api_key",
  "model": "gpt-4o"
}
EOF
    
    log "OpenAI configuration saved"
    test_configuration
}

configure_claude() {
    echo -n "Enter your Anthropic API key: "
    read -r api_key
    
    cat > "$CONFIG_DIR/config.json" <<EOF
{
  "type": "Claude",
  "apiKey": "$api_key",
  "model": "claude-3-5-sonnet-20241022"
}
EOF
    
    log "Claude configuration saved"
    test_configuration
}

configure_local() {
    title "Local model setup requires llama.cpp:"
    echo "1. Install llama.cpp: git clone https://github.com/ggerganov/llama.cpp.git"
    echo "2. Build it: cd llama.cpp && make llama-server"
    echo "3. Set LLAMA_DIR: export LLAMA_DIR=/path/to/llama.cpp"
    echo ""
    echo "Choose a model:"
    echo "1. gemma-3-4b (Recommended, 4B parameters)"
    echo "2. smollm3-3b (Balanced, 3B parameters)"
    echo "3. tinyllama-1.1b (Fastest, 1.1B parameters)"
    
    echo -n "Enter your choice (1-3): "
    read -r model_choice
    
    case $model_choice in
        1) model="gemma-3-4b" ;;
        2) model="smollm3-3b" ;;
        3) model="tinyllama-1.1b" ;;
        *) model="gemma-3-4b" ;;
    esac
    
    cat > "$CONFIG_DIR/config.json" <<EOF
{
  "type": "LlamaCpp",
  "model": "$model",
  "contextSize": 2048,
  "temperature": 0.1,
  "maxTokens": 150,
  "port": 8080
}
EOF
    
    log "Local model configuration saved"
    warn "Remember to set LLAMA_DIR environment variable!"
}

test_configuration() {
    log "Testing configuration..."
    
    if command_exists kok-cli; then
        if kok-cli "echo hello world" >/dev/null 2>&1; then
            log "Configuration test passed!"
        else
            warn "Configuration test failed. Check your API key or setup."
        fi
    fi
}

# Print success message
print_success() {
    title "🎉 kok installation complete!"
    echo ""
    log "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Test with: kok 'list files in current directory'"
    echo "  3. Check status with: kok_status"
    echo "  4. Get help with: kok_help"
    echo ""
    info "Configuration file: $CONFIG_DIR/config.json"
    info "Binary location: $(which kok-cli 2>/dev/null || echo "~/.local/bin/kok-cli")"
    echo ""
    title "Happy command generating! 🚀"
}

# Main installation flow
main() {
    title "🚀 Installing kok - Natural language to shell commands"
    echo ""
    
    # Detect system
    detect_os
    log "Detected OS: $OS, Architecture: $ARCH"
    
    # Check dependencies
    if ! command_exists curl; then
        error "curl is required but not installed"
        exit 1
    fi
    
    # Create directories
    create_directories
    
    # Install Bun
    install_bun
    
    # Install kok
    install_kok
    
    # Install shell functions
    install_shell_functions
    
    # Configure
    configure_kok
    
    # Success message
    print_success
}

# Run installation
main "$@"