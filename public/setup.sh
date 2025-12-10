#!/bin/bash

# LocalDev + Ollama Universal Setup Script
# Detects OS and installs LocalDev with Ollama and pre-loaded models

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

print_info() {
  echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

# Header
echo -e "${BLUE}"
echo "╔════════════════════════════════════════╗"
echo "║   LocalDev + Ollama Setup Script      ║"
echo "║   Universal Installer                 ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# Step 1: Detect OS
print_info "Detecting operating system..."
OS_TYPE="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS_TYPE="linux"
  DISTRO="unknown"
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
      DISTRO="debian"
    elif [[ "$ID" == "fedora" ]]; then
      DISTRO="fedora"
    elif [[ "$ID" == "arch" ]]; then
      DISTRO="arch"
    fi
  fi
  print_success "Detected: Linux ($DISTRO)"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS_TYPE="macos"
  print_success "Detected: macOS"
else
  print_error "Unsupported OS: $OSTYPE"
  exit 1
fi

# Step 2: Check prerequisites
print_info "Checking prerequisites..."

# Check for curl
if ! command -v curl &> /dev/null; then
  print_warning "curl not found. Attempting to install..."
  if [[ "$OS_TYPE" == "linux" ]]; then
    if [[ "$DISTRO" == "debian" ]]; then
      sudo apt-get update && sudo apt-get install -y curl
    elif [[ "$DISTRO" == "fedora" ]]; then
      sudo dnf install -y curl
    elif [[ "$DISTRO" == "arch" ]]; then
      sudo pacman -S --noconfirm curl
    fi
  elif [[ "$OS_TYPE" == "macos" ]]; then
    print_error "curl is required but not found. Please install Xcode Command Line Tools: xcode-select --install"
    exit 1
  fi
fi
print_success "curl is available"

# Check for git
if ! command -v git &> /dev/null; then
  print_warning "git not found. Attempting to install..."
  if [[ "$OS_TYPE" == "linux" ]]; then
    if [[ "$DISTRO" == "debian" ]]; then
      sudo apt-get update && sudo apt-get install -y git
    elif [[ "$DISTRO" == "fedora" ]]; then
      sudo dnf install -y git
    elif [[ "$DISTRO" == "arch" ]]; then
      sudo pacman -S --noconfirm git
    fi
  elif [[ "$OS_TYPE" == "macos" ]]; then
    print_error "git is required but not found. Please install Xcode Command Line Tools: xcode-select --install"
    exit 1
  fi
fi
print_success "git is available"

# Step 3: Install Ollama
print_info "Installing Ollama..."
if command -v ollama &> /dev/null; then
  print_success "Ollama is already installed"
else
  if [[ "$OS_TYPE" == "macos" ]]; then
    # macOS installation
    if ! command -v brew &> /dev/null; then
      print_info "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install ollama
  else
    # Linux installation
    curl -fsSL https://ollama.ai/install.sh | sh
  fi

  # Verify installation
  if command -v ollama &> /dev/null; then
    print_success "Ollama installed successfully"
  else
    print_error "Ollama installation failed"
    exit 1
  fi
fi

# Step 4: Start Ollama service
print_info "Starting Ollama service..."
if [[ "$OS_TYPE" == "macos" ]]; then
  # macOS
  if ! pgrep -x "ollama" > /dev/null; then
    ollama serve &
    sleep 3
  fi
elif [[ "$OS_TYPE" == "linux" ]]; then
  # Linux - use systemctl if available
  if command -v systemctl &> /dev/null; then
    sudo systemctl start ollama || true
    sleep 2
  else
    # Fallback to running ollama serve in background
    if ! pgrep -x "ollama" > /dev/null; then
      ollama serve &
      sleep 3
    fi
  fi
fi

# Check if Ollama is running
if pgrep -x "ollama" > /dev/null; then
  print_success "Ollama service is running"
else
  print_warning "Could not verify Ollama service. It may start automatically."
fi

# Step 5: Pull required models
print_info "Pulling AI models (this may take a few minutes)..."

print_info "Pulling llama3..."
ollama pull llama3
print_success "llama3 model loaded"

print_info "Pulling nomic-embed-text..."
ollama pull nomic-embed-text
print_success "nomic-embed-text model loaded"

# Step 6: Verify setup
print_info "Verifying installation..."
sleep 2
if curl -s http://localhost:11434/api/tags &> /dev/null; then
  print_success "Ollama API is responding correctly"
else
  print_warning "Ollama API not responding on localhost:11434"
fi

# Final message
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation Complete!              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
print_success "LocalDev + Ollama setup is ready!"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  • Ollama is running on http://localhost:11434"
echo "  • Models available: llama3, nomic-embed-text"
echo "  • Test with: ollama run llama3 \"Hello\""
echo ""
echo -e "${BLUE}Documentation:${NC}"
echo "  • Ollama Docs: https://github.com/ollama/ollama"
echo "  • API Docs: http://localhost:11434/api"
echo ""
