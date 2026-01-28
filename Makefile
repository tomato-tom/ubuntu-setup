# Makefile for Ubuntu Desktop Setup

.DEFAULT_GOAL := all
SCRIPT_DIR := script

# メインターゲット
.PHONY: all clean help

all: packages keymap fcitx5 neovim obsidian tmux grub dotfiles
	@echo "Ubuntu setup completed!"

# 個別セットアップターゲット
.PHONY: packages keymap fcitx5 neovim obsidian tmux grub dotfiles

packages:
	@echo "Installing packages..."
	@(cd $(SCRIPT_DIR) && ./package_install.sh)

keymap: packages
	@echo "Setting up keymap..."
	@(cd $(SCRIPT_DIR) && sudo ./keymap.sh)

fcitx5: packages
	@echo "Setting up fcitx5..."
	@(cd $(SCRIPT_DIR) && ./fcitx5setup.sh)

neovim: packages
	@echo "Installing neovim..."
	@(cd $(SCRIPT_DIR) && ./install_neovim.sh)

obsidian: packages
	@echo "Updating obsidian..."
	@(cd $(SCRIPT_DIR) && ./obsidian_update.sh)

tmux: neovim
	@echo "Setting up tmux..."
	@(cd $(SCRIPT_DIR) && ./setup_tmux.sh)

grub:
	@echo "Updating grub..."
	@(cd $(SCRIPT_DIR) && ./update_grub.sh)

dotfiles:
	@echo "Sync dotfiles..."
	@(cd $(SCRIPT_DIR) && bash sync_dotfiles.sh)

help:
	@echo "Available targets:"
	@echo "  all       - Run complete setup"
	@echo "  packages  - Install packages"
	@echo "  keymap    - Setup keymap"
	@echo "  fcitx5    - Setup fcitx5"
	@echo "  neovim    - Install neovim"
	@echo "  obsidian  - Update obsidian"
	@echo "  tmux      - Setup tmux"
	@echo "  grub      - Update grub"
	@echo "  dotfiles  - Sync dotfiles"
	@echo "  clean     - Clean logs"

clean:
	@rm -f $(LOG_DIR)/*.log
	@echo "Cleaned logs"
