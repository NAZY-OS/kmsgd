# Makefile for kmsgd daemon
# KISS style, compatible with Linux and BSD

PREFIX ?= /
SBIN_DIR ?= $(PREFIX)/sbin
VAR_RUN_DIR ?= /var/run
RCONF_DIR ?= /etc/rc.d
SYSTEMD_DIR ?= /etc/systemd/system

NAME = kmsgd

check_root:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "ERROR: This installation must be run as root" >&2; \
		exit 1; \
	fi

all: install

install: check_root
	@echo "Running installation script..."
	@chmod +x install_kmsgd.sh
	@./install_kmsgd.sh

uninstall: check_root
	@echo "Uninstalling $(NAME) daemon..."
	@rm -f $(SBIN_DIR)/$(NAME)
	@rm -f $(SBIN_DIR)/$(NAME).sh
	@rm -f $(VAR_RUN_DIR)/$(NAME).pid
	@rm -f $(RCONF_DIR)/$(NAME)  # Entfernt BSD-Init-Skript
	@rm -f $(SYSTEMD_DIR)/$(NAME).service  # Entfernt systemd-Service
	@echo "Uninstall complete"

clean:
	@echo "Cleaning..."

.PHONY: all install uninstall clean check_root
