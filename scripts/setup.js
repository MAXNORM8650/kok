#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import os from 'os';
import { execSync } from 'child_process';
import { createInterface } from 'readline';
import envPaths from 'env-paths';

const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function askQuestion(question) {
  const readline = createInterface({
    input: process.stdin,
    output: process.stdout
  });
  
  return new Promise((resolve) => {
    readline.question(question, (answer) => {
      readline.close();
      resolve(answer.trim());
    });
  });
}

async function detectShell() {
  const shell = process.env.SHELL || '';
  if (shell.includes('zsh')) return 'zsh';
  if (shell.includes('bash')) return 'bash';
  if (shell.includes('fish')) return 'fish';
  return 'unknown';
}

function getShellConfigFile(shell) {
  const home = os.homedir();
  switch (shell) {
    case 'zsh': return path.join(home, '.zshrc');
    case 'bash': return path.join(home, '.bashrc');
    case 'fish': return path.join(home, '.config/fish/config.fish');
    default: return path.join(home, '.profile');
  }
}

function generateShellFunctions(shell) {
  const baseFunctions = `
# kok - Natural language to shell commands
kok() {
  local cmd
  cmd="$(kok-cli "$@")" || return
  echo "Generated: $cmd"
  vared -p "Execute? " -c cmd
  print -s -- "$cmd"
  eval "$cmd"
}

kok_stop() {
  pkill llama-server && echo "🛑 Local AI server stopped"
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
`;

  if (shell === 'fish') {
    return `
# kok - Natural language to shell commands
function kok
    set cmd (kok-cli $argv)
    or return
    echo "Generated: $cmd"
    read -p "Execute? " confirm
    if test "$confirm" = "y" -o "$confirm" = "yes"
        eval $cmd
    end
end

function kok_stop
    pkill llama-server; and echo "🛑 Local AI server stopped"
end

function kok_status
    echo "🤖 kok Configuration:"
    # Fish implementation
end
`;
  }

  return baseFunctions;
}

async function setupShellIntegration() {
  log('\n📝 Setting up shell integration...', 'cyan');
  
  const shell = await detectShell();
  const configFile = getShellConfigFile(shell);
  
  log(`Detected shell: ${shell}`, 'yellow');
  log(`Config file: ${configFile}`, 'yellow');
  
  const setupShell = await askQuestion('Add kok functions to your shell config? (y/n): ');
  
  if (setupShell.toLowerCase() === 'y' || setupShell.toLowerCase() === 'yes') {
    const functions = generateShellFunctions(shell);
    
    try {
      fs.appendFileSync(configFile, functions);
      log('✅ Shell functions added successfully!', 'green');
      log(`Please run: source ${configFile}`, 'yellow');
    } catch (error) {
      log(`❌ Failed to write to ${configFile}`, 'red');
      log('You can manually add the functions shown in the README', 'yellow');
    }
  }
}

async function createConfig() {
  log('\n🔧 Setting up configuration...', 'cyan');
  
  const paths = envPaths('kok', { suffix: '' });
  const configPath = path.join(paths.config, 'config.json');
  
  if (fs.existsSync(configPath)) {
    log('Configuration already exists!', 'yellow');
    const overwrite = await askQuestion('Overwrite existing config? (y/n): ');
    if (overwrite.toLowerCase() !== 'y' && overwrite.toLowerCase() !== 'yes') {
      return;
    }
  }
  
  log('\nChoose your AI provider:', 'bright');
  log('1. OpenAI (GPT-4, requires API key)');
  log('2. Claude (Anthropic, requires API key)');
  log('3. Gemini (Google, requires API key)');
  log('4. Local models (llama.cpp, no API key needed)');
  log('5. Custom (Ollama, etc.)');
  
  const choice = await askQuestion('\nEnter your choice (1-5): ');
  
  let config = {};
  
  switch (choice) {
    case '1':
      const openaiKey = await askQuestion('Enter your OpenAI API key (or press Enter to use OPENAI_API_KEY env var): ');
      config = {
        type: "OpenAI",
        apiKey: openaiKey || "",
        model: "gpt-4o"
      };
      break;
      
    case '2':
      const claudeKey = await askQuestion('Enter your Anthropic API key: ');
      config = {
        type: "Claude",
        apiKey: claudeKey,
        model: "claude-3-5-sonnet-20241022"
      };
      break;
      
    case '3':
      const geminiKey = await askQuestion('Enter your Google API key: ');
      config = {
        type: "Gemini",
        apiKey: geminiKey,
        model: "gemini-1.5-pro"
      };
      break;
      
    case '4':
      log('\nChoose a local model:', 'bright');
      log('1. gemma-3-4b (Recommended, 4B parameters)');
      log('2. smollm3-3b (Balanced, 3B parameters)');
      log('3. tinyllama-1.1b (Fastest, 1.1B parameters)');
      
      const modelChoice = await askQuestion('Enter your choice (1-3): ');
      const models = {
        '1': 'gemma-3-4b',
        '2': 'smollm3-3b',
        '3': 'tinyllama-1.1b'
      };
      
      config = {
        type: "LlamaCpp",
        model: models[modelChoice] || 'gemma-3-4b',
        contextSize: 2048,
        temperature: 0.1,
        maxTokens: 150,
        port: 8080
      };
      
      log('\n📋 For local models, make sure to:', 'yellow');
      log('1. Install llama.cpp: git clone https://github.com/ggerganov/llama.cpp.git');
      log('2. Build it: cd llama.cpp && make llama-server');
      log('3. Set LLAMA_DIR: export LLAMA_DIR=/path/to/llama.cpp');
      break;
      
    case '5':
      const baseURL = await askQuestion('Enter base URL (e.g., http://localhost:11434/v1): ');
      const model = await askQuestion('Enter model name (e.g., llama3.1): ');
      const apiKey = await askQuestion('Enter API key (or "ollama" for Ollama): ');
      
      config = {
        type: "Custom",
        baseURL: baseURL,
        model: model,
        apiKey: apiKey
      };
      break;
      
    default:
      log('Invalid choice, using default OpenAI config', 'yellow');
      config = {
        type: "OpenAI",
        apiKey: "",
        model: "gpt-4o"
      };
  }
  
  try {
    fs.mkdirSync(paths.config, { recursive: true });
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
    log(`✅ Configuration saved to: ${configPath}`, 'green');
  } catch (error) {
    log(`❌ Failed to save configuration: ${error.message}`, 'red');
  }
}

function checkBinary() {
  const binaryPath = path.join(process.cwd(), 'dist', 'kok-cli');
  if (!fs.existsSync(binaryPath)) {
    log('❌ Binary not found. Please run: bun run build', 'red');
    return false;
  }
  return true;
}

function installBinary() {
  log('\n🔧 Installing kok-cli binary...', 'cyan');
  
  const binaryPath = path.join(process.cwd(), 'dist', 'kok-cli');
  const targetPath = '/usr/local/bin/kok-cli';
  
  try {
    execSync(`chmod +x ${binaryPath}`);
    execSync(`sudo cp ${binaryPath} ${targetPath}`);
    log('✅ Binary installed successfully!', 'green');
    return true;
  } catch (error) {
    log(`❌ Failed to install binary: ${error.message}`, 'red');
    log('You may need to run with sudo or install manually', 'yellow');
    return false;
  }
}

async function main() {
  log('🚀 Welcome to kok setup!', 'bright');
  log('This will help you configure kok for natural language shell commands.\n', 'cyan');
  
  // Check if binary exists
  if (!checkBinary()) {
    log('Please build the project first with: bun run build', 'yellow');
    return;
  }
  
  // Install binary
  const shouldInstall = await askQuestion('Install kok-cli to /usr/local/bin? (y/n): ');
  if (shouldInstall.toLowerCase() === 'y' || shouldInstall.toLowerCase() === 'yes') {
    installBinary();
  }
  
  // Create configuration
  await createConfig();
  
  // Setup shell integration
  await setupShellIntegration();
  
  log('\n🎉 Setup complete!', 'green');
  log('\nNext steps:', 'bright');
  log('1. Restart your terminal or run: source ~/.zshrc', 'yellow');
  log('2. Test with: kok "list files in current directory"', 'yellow');
  log('3. Check status with: kok_status', 'yellow');
  
  if (fs.existsSync(path.join(process.cwd(), 'README.md'))) {
    log('\n📖 For more information, see README.md', 'cyan');
  }
}

main().catch(console.error);