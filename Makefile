# kok - Natural language to shell commands
# Makefile for building and installing

.PHONY: help build install clean test dev setup uninstall

# Default target
help:
	@echo "🚀 kok - Natural language to shell commands"
	@echo ""
	@echo "Available targets:"
	@echo "  build      - Build the kok-cli binary"
	@echo "  install    - Install kok-cli to /usr/local/bin"
	@echo "  setup      - Run interactive setup wizard"
	@echo "  dev        - Run in development mode"
	@echo "  test       - Run tests"
	@echo "  clean      - Clean build artifacts"
	@echo "  uninstall  - Remove installed binary"
	@echo "  help       - Show this help message"

# Check for required tools
check-deps:
	@which bun > /dev/null || (echo "❌ Bun is required. Install from https://bun.sh" && exit 1)
	@echo "✅ Dependencies check passed"

# Build the binary
build: check-deps
	@echo "🔨 Building kok-cli..."
	@bun install
	@bun run build
	@chmod +x dist/kok-cli
	@echo "✅ Built dist/kok-cli"

# Development mode
dev: check-deps
	@echo "🔧 Running in development mode..."
	@bun run dev $(ARGS)

# Run tests
test: check-deps
	@echo "🧪 Running tests..."
	@bun test

# Interactive setup
setup: build
	@echo "⚙️ Running setup wizard..."
	@node scripts/setup.js

# Install to system
install: build
	@echo "📦 Installing kok-cli to /usr/local/bin..."
	@sudo cp dist/kok-cli /usr/local/bin/kok-cli
	@sudo chmod +x /usr/local/bin/kok-cli
	@echo "✅ Installed successfully!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Run 'make setup' to configure"
	@echo "2. Add shell functions to your ~/.zshrc:"
	@echo "   curl -s https://raw.githubusercontent.com/your-repo/kok/main/shell-functions.sh >> ~/.zshrc"
	@echo "3. Restart your terminal"
	@echo "4. Test with: kok 'list files'"

# Quick install for development
install-dev: build
	@echo "📦 Installing kok-cli for development..."
	@cp dist/kok-cli /usr/local/bin/kok-cli
	@chmod +x /usr/local/bin/kok-cli
	@echo "✅ Development install complete!"

# Uninstall
uninstall:
	@echo "🗑️ Uninstalling kok-cli..."
	@sudo rm -f /usr/local/bin/kok-cli
	@echo "✅ Uninstalled successfully!"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf dist/
	@rm -rf node_modules/.cache/
	@echo "✅ Cleaned"

# Full clean (including node_modules)
clean-all: clean
	@echo "🧹 Full clean..."
	@rm -rf node_modules/
	@echo "✅ Full clean complete"

# Package for distribution
package: build
	@echo "📦 Creating distribution package..."
	@mkdir -p dist/package
	@cp dist/kok-cli dist/package/
	@cp README.md dist/package/
	@cp LICENSE dist/package/
	@cp -r configs/ dist/package/
	@tar -czf dist/kok-$(shell date +%Y%m%d).tar.gz -C dist/package .
	@echo "✅ Package created: dist/kok-$(shell date +%Y%m%d).tar.gz"

# Quick test with sample command
test-quick: build
	@echo "🧪 Quick test..."
	@echo "Testing with: 'echo hello world'"
	@./dist/kok-cli "echo hello world"

# Show configuration
config-info:
	@echo "📋 Configuration Information:"
	@echo "Config file locations:"
	@echo "  Linux:   ~/.config/kok/config.json"
	@echo "  macOS:   ~/Library/Application Support/kok/config.json"
	@echo "  Windows: %APPDATA%\\kok\\config.json"
	@echo ""
	@if [ -f ~/.config/kok/config.json ]; then \
		echo "Current config:"; \
		cat ~/.config/kok/config.json | head -10; \
	else \
		echo "No config file found. Run 'make setup' to create one."; \
	fi

# Installation verification
verify-install:
	@echo "🔍 Verifying installation..."
	@which kok-cli > /dev/null && echo "✅ kok-cli found in PATH" || echo "❌ kok-cli not found in PATH"
	@kok-cli --version 2>/dev/null && echo "✅ kok-cli is executable" || echo "❌ kok-cli not executable"
	@echo "Testing basic functionality..."
	@kok-cli "echo hello" > /dev/null 2>&1 && echo "✅ Basic test passed" || echo "❌ Basic test failed - check configuration"

# Development helpers
format:
	@echo "🎨 Formatting code..."
	@bun run prettier --write "**/*.{ts,js,json,md}"

lint:
	@echo "🔍 Linting code..."
	@bun run eslint "**/*.{ts,js}"

# Generate shell completion (if needed later)
completion:
	@echo "🔧 Generating shell completion..."
	@echo "# kok completion not yet implemented"

# Print useful information
info:
	@echo "📊 kok Information:"
	@echo "Version: $(shell grep version package.json | cut -d'"' -f4)"
	@echo "Binary: $(shell ls -la dist/kok-cli 2>/dev/null || echo 'Not built')"
	@echo "Config: $(shell ls -la ~/.config/kok/config.json 2>/dev/null || echo 'Not configured')"
	@echo "Dependencies:"
	@echo "  Bun: $(shell bun --version 2>/dev/null || echo 'Not installed')"
	@echo "  Node: $(shell node --version 2>/dev/null || echo 'Not installed')"