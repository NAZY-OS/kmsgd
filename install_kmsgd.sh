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

    # Create directories only if they don't exist
    [ -d "${SBIN_DIR}" ] || mkdir -p "${SBIN_DIR}"
    [ -d "${VAR_RUN_DIR}" ] || mkdir -p "${VAR_RUN_DIR}"

    # Install main files only if they don't exist
    [ -f "${SBIN_DIR}/${NAME}" ] || install -m 755 kmsgd "${SBIN_DIR}/"
    [ -f "${SBIN_DIR}/${NAME}.sh" ] || install -m 755 kmsgd.sh "${SBIN_DIR}/"

    # Create PID file only if it doesn't exist
    [ -f "${VAR_RUN_DIR}/${NAME}.pid" ] || {
        touch "${VAR_RUN_DIR}/${NAME}.pid"
        chmod 644 "${VAR_RUN_DIR}/${NAME}.pid"
    }

    echo "Files installed to ${SBIN_DIR}"
}

install_init_systemd() {
    if [ -d "${SYSTEMD_DIR}" ]; then
        echo "Installing systemd service..."
        [ -f "${SYSTEMD_DIR}/${NAME}.service" ] || {
            install -m 644 kmsgd.service "${SYSTEMD_DIR}/"
            systemctl daemon-reload || true
            echo "Run 'systemctl enable --now ${NAME}' to start the daemon"
        }
    else
        echo "systemd not detected (skipping systemd service)"
    fi
}

install_init_bsd() {
    if [ -d "${RCONF_DIR}" ] && [ -d "${INIT_DIR}" ]; then
        echo "Installing BSD-style init script..."
        [ -f "${RCONF_DIR}/${NAME}" ] || {
            install -m 755 kmsgd.init "${RCONF_DIR}/"
            echo "Run '/etc/rc.d/${NAME} start' to start the daemon"
        }
    else
        echo "BSD rc system not detected (skipping BSD init script)"
    fi
}

## MAIN
check_root
install_files
install_init_systemd
install_init_bsd
echo "Installation complete"
