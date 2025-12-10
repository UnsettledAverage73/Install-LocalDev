# LocalDev + Ollama Setup Script for Windows (PowerShell)
# To run: iwr -useb https://your-site.com/setup.ps1 | iex

# Function to print colored output
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

# Header
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   LocalDev + Ollama Setup Script      ║" -ForegroundColor Cyan
Write-Host "║   Windows Installer                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if running as administrator
Write-Info "Checking administrator privileges..."
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Warning-Custom "This script requires administrator privileges. Please run PowerShell as Administrator."
    exit 1
}
Write-Success "Running with administrator privileges"

# Step 2: Check prerequisites
Write-Info "Checking prerequisites..."

# Check for Git
$gitPath = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitPath) {
    Write-Warning-Custom "Git is not installed. Please install Git from https://git-scm.com/download/win"
    exit 1
}
Write-Success "Git is available"

# Step 3: Check if Ollama is installed
Write-Info "Checking for Ollama..."
$ollamaPath = Get-Command ollama -ErrorAction SilentlyContinue

if (-not $ollamaPath) {
    Write-Warning-Custom "Ollama is not installed. Please download and install from https://ollama.ai/download/windows"
    Write-Info "After installation, run this script again."
    exit 1
}
Write-Success "Ollama is installed"

# Step 4: Start Ollama service
Write-Info "Starting Ollama service..."
# On Windows, Ollama should be installed as a service
if (Get-Service -Name "Ollama" -ErrorAction SilentlyContinue) {
    Start-Service -Name "Ollama" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Success "Ollama service started"
} else {
    Write-Warning-Custom "Ollama service not found. Make sure Ollama is properly installed."
}

# Step 5: Pull required models
Write-Info "Pulling AI models (this may take a few minutes)..."

Write-Info "Pulling llama3..."
& ollama pull llama3
Write-Success "llama3 model loaded"

Write-Info "Pulling nomic-embed-text..."
& ollama pull nomic-embed-text
Write-Success "nomic-embed-text model loaded"

# Step 6: Verify setup
Write-Info "Verifying installation..."
Start-Sleep -Seconds 2

try {
    $response = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Success "Ollama API is responding correctly"
    }
} catch {
    Write-Warning-Custom "Ollama API not responding on localhost:11434"
}

# Final message
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   Installation Complete!              ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Success "LocalDev + Ollama setup is ready!"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  • Ollama is running on http://localhost:11434"
Write-Host "  • Models available: llama3, nomic-embed-text"
Write-Host "  • Test with: ollama run llama3 'Hello'"
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Cyan
Write-Host "  • Ollama Docs: https://github.com/ollama/ollama"
Write-Host "  • API Docs: http://localhost:11434/api"
Write-Host ""
