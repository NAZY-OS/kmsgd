#!/bin/sh
# Installation script for kmsgd daemon
# KISS style, compatible with Linux and BSD

set -eu

## CONFIG
NAME="kmsgd"
PREFIX="/usr/local"
SBIN_DIR="${PREFIX}/sbin"
VAR_RUN_DIR="/var/run"
SYSTEMD_DIR="/etc/systemd/system"
RCONF_DIR="/etc/rc.d"
INIT_DIR="/etc/init.d"

## FUNCTIONS
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "ERROR: This script must be run as root" >&2
        exit 1
    fi
}

install_files() {
    echo "Installing ${NAME} daemon..."

    # Create directories
    mkdir -p "${SBIN_DIR}"
    mkdir -p "${VAR_RUN_DIR}"

    # Install main files
    install -m 755 kmsgd "${SBIN_DIR}/"
    install -m 755 kmsgd.sh "${SBIN_DIR}/"

    # Create PID directory
    touch "${VAR_RUN_DIR}/${NAME}.pid"
    chmod 644 "${VAR_RUN_DIR}/${NAME}.pid"

    echo "Files installed to ${SBIN_DIR}"
}

install_init() {
    # Try systemd first
    if [ -d "${SYSTEMD_DIR}" ]; then
        echo "Installing systemd service..."
        install -m 644 "${NAME}.service" "${SYSTEMD_DIR}/"
        systemctl daemon-reload
        echo "Run 'systemctl enable --now ${NAME}' to start the daemon"
        return
    fi

    # Try BSD-style init
    if [ -d "${RCONF_DIR}" ] && [ -d "${INIT_DIR}" ]; then
        echo "Installing BSD-style init script..."
        install -m 755 "${NAME}.init" "${INIT_DIR}/"
        echo "Run '/etc/rc.d/${NAME} start' to start the daemon"
        return
    fi

    # Fallback to basic instructions
    echo "No init system detected"
    echo "To start the daemon manually:"
    echo "  ${SBIN_DIR}/${NAME} start"
}

## MAIN
check_root
install_files
install_init
echo "Installation complete"
