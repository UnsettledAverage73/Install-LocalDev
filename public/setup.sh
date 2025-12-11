#!/bin/bash

# --- CONFIGURATION ---
# The link to your specific release
APP_URL="https://github.com/UnsettledAverage73/Locally-AI-Integrated-IDE/releases/download/v.1.0.0/LocalDev-1.0.0.AppImage"
INSTALL_DIR="$HOME/LocalDev"
APP_NAME="LocalDev.AppImage"

# Only installing the coding model and embedding model
MODELS=("deepseek-coder" "nomic-embed-text")

# Colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting LocalDev AI IDE Installation...${NC}"

# 1. Download AppImage
echo -e "${BLUE}⬇️  Downloading LocalDev AppImage...${NC}"
# Create directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Download with a progress bar
if curl -L "$APP_URL" -o "$INSTALL_DIR/$APP_NAME"; then
    chmod +x "$INSTALL_DIR/$APP_NAME"
    echo -e "${GREEN}✅ AppImage Downloaded to $INSTALL_DIR/$APP_NAME${NC}"
else
    echo -e "${RED}❌ Failed to download AppImage. Please check the URL or internet connection.${NC}"
    exit 1
fi

# 2. Install Ollama (if missing)
if ! command -v ollama &> /dev/null; then
    echo -e "${BLUE}🦙 Ollama not found. Installing...${NC}"
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo -e "${GREEN}✅ Ollama is already installed.${NC}"
fi

# 3. Start Ollama Service
echo -e "${BLUE}🔌 Checking Ollama Service...${NC}"
# Check if ollama is running
if ! pgrep -x "ollama" > /dev/null; then
    echo "   Starting Ollama server in background..."
    ollama serve > /dev/null 2>&1 &
    
    # Wait loop to ensure it's ready before pulling models
    echo "   Waiting for AI engine to initialize..."
    sleep 5
else
    echo -e "${GREEN}✅ Ollama is already running.${NC}"
fi

# 4. Pull AI Models
echo -e "${BLUE}🧠 Downloading AI Brains (DeepSeek & Nomic)...${NC}"
for model in "${MODELS[@]}"; do
    echo -e "   ⬇️  Pulling model: $model..."
    ollama pull "$model"
done

# 5. Finalize
echo -e "\n${GREEN}🎉 Installation Complete!${NC}"
echo -e "To start the app, run:"
echo -e "${BLUE}$INSTALL_DIR/$APP_NAME${NC}"
echo -e "\n(You can also double-click the AppImage file in your $INSTALL_DIR folder)"

# Optional: Launch immediately
read -p "Do you want to launch LocalDev now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    "$INSTALL_DIR/$APP_NAME" &
fi
