SHELL         := /usr/bin/env bash
MAKEFLAGS     += --silent

-include .env
export

VSCODE_DIR      := .vscode
EXTENSIONS_FILE := extensions.json

CODE_CMD        := code
CURSOR_CMD      := cursor

define export_extensions
	echo "Exporting installed $(1) extensions to $(VSCODE_DIR)/$(EXTENSIONS_FILE)..."
	mkdir -p $(VSCODE_DIR)
	$(SHELL) -c 'echo "{\"extensions\": [" > "$(VSCODE_DIR)/$(EXTENSIONS_FILE)" && \
		$(2) --list-extensions | awk "{ printf \"\\\"%s\\\",\", \$$1 }" | sed "s/,$$//" >> "$(VSCODE_DIR)/$(EXTENSIONS_FILE)" && \
		echo "]}" >> "$(VSCODE_DIR)/$(EXTENSIONS_FILE)"'
	echo "Exported installed $(1) extensions to $(VSCODE_DIR)/$(EXTENSIONS_FILE)."
endef

define install_extensions
	echo "Installing $(1) extensions from $(VSCODE_DIR)/$(EXTENSIONS_FILE)..."
	[ -f "$(VSCODE_DIR)/$(EXTENSIONS_FILE)" ] || { echo "Error: $(VSCODE_DIR)/$(EXTENSIONS_FILE) not found"; exit 1; }
	$(SHELL) -c 'cat "$(VSCODE_DIR)/$(EXTENSIONS_FILE)" | grep -o "\"[^\"]*\"" | tr -d "\"" | while read ext; do \
		echo "Installing $$ext..."; \
		$(2) --install-extension $$ext || echo "Failed to install $$ext"; \
	done'
	echo "Installed $(1) extensions from $(VSCODE_DIR)/$(EXTENSIONS_FILE)."
endef

default: help

.PHONY: help
help: ## Show the available commands
	echo "Available commands:"
	grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: export-code-extensions
export-code-extensions: ## Export the installed VSCode extensions to a JSON file
	$(call export_extensions,VSCode,$(CODE_CMD))

.PHONY: export-cursor-extensions
export-cursor-extensions: ## Export the installed Cursor extensions to a JSON file
	$(call export_extensions,Cursor,$(CURSOR_CMD))

.PHONY: install-code-extensions
install-code-extensions: ## Install VSCode extensions from the JSON file
	$(call install_extensions,VSCode,$(CODE_CMD))

.PHONY: install-cursor-extensions
install-cursor-extensions: ## Install Cursor extensions from the JSON file
	$(call install_extensions,Cursor,$(CURSOR_CMD))
