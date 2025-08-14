# kok - Complete Project Structure

This document outlines the complete file structure for the kok package.

## 📁 Project Layout

```
kok/
├── 📄 package.json              # Main package configuration
├── 📄 index.ts                  # Main application entry point
├── 📄 tsconfig.json             # TypeScript configuration
├── 📄 Makefile                  # Build and installation commands
├── 📄 README.md                 # Comprehensive documentation
├── 📄 LICENSE                   # MIT license
├── 📄 install.sh                # One-click installation script
├── 📄 shell-functions.sh        # Shell integration functions
├── 📁 scripts/
│   └── 📄 setup.js              # Interactive setup wizard
├── 📁 configs/
│   └── 📄 README.md             # Configuration examples
└── 📁 dist/                     # Build output (created after build)
    └── 📄 kok-cli               # Compiled binary
```

## 🚀 Quick Start

### Method 1: One-line install
```bash
curl -s https://raw.githubusercontent.com/your-repo/kok/main/install.sh | bash
```

### Method 2: Manual installation
```bash
# Clone and build
git clone https://github.com/your-repo/kok.git
cd kok
make install

# Interactive setup
make setup
```

### Method 3: Development setup
```bash
git clone https://github.com/your-repo/kok.git
cd kok
bun install
bun run build
./dist/kok-cli "test command"
```

## 📋 Key Features

### ✨ Multiple AI Providers
- **OpenAI GPT-4o**: Cloud-based, high quality
- **Claude 3.5 Sonnet**: Anthropic's latest model
- **Google Gemini**: Google's AI model
- **Local Models**: Privacy-focused llama.cpp integration
- **Custom/Ollama**: Support for self-hosted models

### 🛠️ Easy Configuration
- Interactive setup wizard
- Environment variable support
- Multiple configuration methods
- Auto-detection of optimal settings

### 💻 Shell Integration
- Interactive command editing
- Command history integration
- Cross-shell compatibility (zsh, bash, fish)
- Helper functions and utilities

### 🔧 Development Tools
- Comprehensive Makefile
- TypeScript support
- Automated testing
- Code formatting and linting

## 📝 Configuration Examples

### OpenAI Setup
```json
{
  "type": "OpenAI",
  "apiKey": "sk-your_api_key_here",
  "model": "gpt-4o"
}
```

### Local Models Setup
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

## 🔍 Usage Examples

```bash
# Basic commands
kok "list all files in this directory"
kok "create a new directory called projects"
kok "find all .js files modified in the last week"

# System operations
kok "check disk usage for current directory"
kok "show running processes using port 3000"
kok "compress all log files older than 30 days"

# Git operations
kok "create a new branch called feature-auth"
kok "commit all changes with message 'fix bug'"
kok "show git log for the last 10 commits"

# Helper functions
kok_status    # Show configuration
kok_stop      # Stop local AI server
kok_test      # Test basic functionality
```

## 🛡️ Security & Privacy

- **API Keys**: Stored locally, never transmitted except to chosen provider
- **Local Models**: Complete privacy, no data leaves your machine
- **Command History**: Standard shell history, no external logging
- **Open Source**: Full transparency, audit-able code

## 🎯 Use Cases

### For Developers
- Quickly generate complex Git commands
- File operations and system administration
- Network debugging and process management
- Development environment setup

### For System Administrators
- Server maintenance commands
- Log analysis and monitoring
- User and permission management
- Automated backup and cleanup scripts

### For General Users
- File organization and management
- System information and diagnostics
- Network connectivity testing
- Basic automation tasks

## 🔧 Advanced Features

### Environment Context
- Automatic detection of OS and shell
- Current directory awareness
- Available tools and commands detection
- Shell history integration

### Performance Optimization
- Local model caching
- Background server management
- Efficient command generation
- Minimal resource usage

### Extensibility
- Plugin architecture ready
- Custom provider support
- Configurable prompts and templates
- Integration with existing tools

## 📦 Distribution

### Package Contents
- Pre-compiled binary for multiple platforms
- Complete documentation and examples
- Interactive setup and configuration
- Shell integration scripts

### Installation Methods
- One-line curl/wget installation
- Package manager distribution (future)
- Docker container support (future)
- Direct binary download

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Testing
```bash
make test          # Run test suite
make test-quick    # Quick functionality test
make verify-install # Verify installation
```

### Code Style
- TypeScript with strict mode
- ESLint and Prettier formatting
- Comprehensive error handling
- Clear documentation

## 📈 Roadmap

### Version 1.0 (Current)
- ✅ Core functionality
- ✅ Multiple AI providers
- ✅ Shell integration
- ✅ Local model support

### Version 1.1 (Planned)
- 🔄 Plugin system
- 🔄 Custom prompt templates
- 🔄 Command history analysis
- 🔄 Batch command processing

### Version 2.0 (Future)
- 🔮 GUI interface
- 🔮 Cloud synchronization
- 🔮 Team collaboration features
- 🔮 Advanced AI capabilities

## 📞 Support

- **Documentation**: README.md and in-code comments
- **Issues**: GitHub issue tracker
- **Discussions**: GitHub discussions
- **Wiki**: Comprehensive guides and tutorials

---

<div align="center">
  <p><strong>kok</strong> - Transform your thoughts into shell commands</p>
  <p>Built with ❤️ for the command-line community</p>
</div>