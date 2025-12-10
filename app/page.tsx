"use client"

import { useState, useEffect } from "react"
import { Copy, CheckCircle, Github } from "lucide-react"

export default function Home() {
  const [os, setOs] = useState<"mac" | "linux" | "windows" | null>(null)
  const [copied, setCopied] = useState(false)

  useEffect(() => {
    // Detect operating system
    const userAgent = navigator.userAgent.toLowerCase()
    if (userAgent.includes("darwin") || userAgent.includes("mac")) {
      setOs("mac")
    } else if (userAgent.includes("linux")) {
      setOs("linux")
    } else if (userAgent.includes("win")) {
      setOs("windows")
    } else {
      // Default to Mac/Linux command
      setOs("mac")
    }
  }, [])

  const commands = {
    mac: "curl -fsSL https://your-site.com/setup.sh | sh",
    linux: "curl -fsSL https://your-site.com/setup.sh | sh",
    windows: "iwr -useb https://your-site.com/setup.ps1 | iex",
  }

  const currentCommand = os ? commands[os] : commands.mac

  const copyToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(currentCommand)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch (err) {
      console.error("Failed to copy:", err)
    }
  }

  return (
    <div className="min-h-screen bg-black text-white flex flex-col">
      {/* Background gradient accent */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-1/2 -right-1/2 w-full h-full bg-gradient-to-br from-cyan-500/5 via-transparent to-transparent blur-3xl" />
        <div className="absolute -bottom-1/2 -left-1/2 w-full h-full bg-gradient-to-tr from-blue-500/5 via-transparent to-transparent blur-3xl" />
      </div>

      {/* Main content */}
      <main className="relative flex-1 flex flex-col items-center justify-center px-4 py-20">
        {/* Hero section */}
        <div className="text-center mb-16 max-w-2xl mx-auto">
          <h1 className="text-5xl md:text-7xl font-bold mb-6 tracking-tight">
            Install{" "}
            <span className="bg-gradient-to-r from-cyan-400 to-blue-500 bg-clip-text text-transparent">LocalDev</span> +
            AI
            <br />
            <span className="text-cyan-400">in One Line</span>
          </h1>
          <p className="text-xl text-gray-400 mb-2">Get LocalDev and Ollama with all models pre-loaded in seconds</p>
          <p className="text-sm text-gray-500">Compatible with macOS, Linux, and Windows</p>
        </div>

        {/* Command box */}
        <div className="w-full max-w-2xl mx-auto mb-12">
          <div className="bg-gray-950 border border-cyan-500/30 rounded-lg p-6 backdrop-blur">
            {/* Label */}
            <div className="mb-4">
              <p className="text-xs uppercase tracking-widest text-cyan-400 font-semibold">
                {os === "windows" ? "PowerShell" : "Terminal"} Command
              </p>
            </div>

            {/* Code block */}
            <div className="relative">
              <code className="block font-mono text-sm md:text-base text-cyan-300 break-all pr-12">
                {currentCommand}
              </code>

              {/* Copy button */}
              <button
                onClick={copyToClipboard}
                className="absolute top-0 right-0 p-2 text-gray-400 hover:text-cyan-400 transition-colors"
                title="Copy to clipboard"
              >
                {copied ? <CheckCircle className="w-5 h-5 text-green-400" /> : <Copy className="w-5 h-5" />}
              </button>
            </div>

            {/* Feedback text */}
            {copied && (
              <div className="mt-4 text-sm text-green-400 flex items-center gap-2">
                <CheckCircle className="w-4 h-4" />
                Copied to clipboard!
              </div>
            )}
          </div>

          {/* OS Detection info */}
          {os && (
            <p className="text-xs text-gray-500 mt-3 text-center">
              Detected: <span className="text-cyan-400 font-mono">{os.toUpperCase()}</span>
            </p>
          )}
        </div>

        {/* Features */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full max-w-3xl mx-auto mb-12">
          <div className="bg-gray-950/50 border border-gray-800 rounded-lg p-4">
            <p className="text-cyan-400 font-semibold mb-2">⚡ Lightning Fast</p>
            <p className="text-sm text-gray-400">Fully automated setup with zero manual configuration</p>
          </div>
          <div className="bg-gray-950/50 border border-gray-800 rounded-lg p-4">
            <p className="text-cyan-400 font-semibold mb-2">🤖 Pre-Loaded Models</p>
            <p className="text-sm text-gray-400">Includes llama3 and nomic-embed-text out of the box</p>
          </div>
          <div className="bg-gray-950/50 border border-gray-800 rounded-lg p-4">
            <p className="text-cyan-400 font-semibold mb-2">🛡️ Reliable</p>
            <p className="text-sm text-gray-400">Service health checks and auto-recovery built in</p>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="relative border-t border-gray-900 py-8 px-4">
        <div className="max-w-6xl mx-auto flex items-center justify-between">
          <p className="text-sm text-gray-500">LocalDev • Bringing AI development to your machine</p>
          <a
            href="https://github.com/yourorg/localdev"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-2 text-gray-400 hover:text-cyan-400 transition-colors"
          >
            <Github className="w-5 h-5" />
            <span className="text-sm">GitHub</span>
          </a>
        </div>
      </footer>
    </div>
  )
}
