# ~/.zshenv - Always sourced by all zsh instances
# This file is loaded for ALL zsh shells (login, non-login, interactive, non-interactive)
# Perfect for PATH modifications that need to be available everywhere

# Add local bin to PATH
export PATH="$PATH:$HOME/.local/bin"

# Add opencode/claude to PATH (for dropdown terminal and all shells)
export PATH="/home/alex/.opencode/bin:$PATH"

# Note: Other shell configurations (aliases, functions, Oh-My-Zsh) are in ~/.zshrc
