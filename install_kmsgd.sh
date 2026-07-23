#!/bin/sh
# Installation script for kmsgd daemon
# KISS style with parameter support

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
usage() {
    echo "Usage: $0 [--prefix PATH] [--help]"
    echo "Options:"
    echo "  --prefix PATH  Install to custom prefix (default: /usr/local)"
    echo "  --help         Show this help message"
    exit 1
}

check_root() {
    [ "$(id -u)" -eq 0 ] || {
        echo "ERROR: This script must be run as root" >&2
        exit 1
    }
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --prefix)
                PREFIX="$2"
                SBIN_DIR="${PREFIX}/sbin"
                VAR_RUN_DIR="${PREFIX}/var/run"
                shift 2
                ;;
            --help)
                usage
                ;;
            *)
                echo "ERROR: Unknown option $1" >&2
                usage
                ;;
        esac
    done
}

install_files() {
    echo "Installing ${NAME} daemon to ${SBIN_DIR}..."

    [ -d "${SBIN_DIR}" ] || mkdir -p "${SBIN_DIR}"
    [ -d "${VAR_RUN_DIR}" ] || mkdir -p "${VAR_RUN_DIR}"

    [ -f "${SBIN_DIR}/${NAME}" ] || install -m 755 kmsgd "${SBIN_DIR}/"
    [ -f "${SBIN_DIR}/${NAME}.sh" ] || install -m 755 kmsgd.sh "${SBIN_DIR}/"

    [ -f "${VAR_RUN_DIR}/${NAME}.pid" ] || {
        touch "${VAR_RUN_DIR}/${NAME}.pid"
        chmod 644 "${VAR_RUN_DIR}/${NAME}.pid"
    }

    echo "Files installed to ${SBIN_DIR}"
}

install_init_systemd() {
    [ -d "${SYSTEMD_DIR}" ] || return

    echo "Installing systemd service..."
    [ -f "${SYSTEMD_DIR}/${NAME}.service" ] || {
        install -m 644 kmsgd.service "${SYSTEMD_DIR}/"
        systemctl daemon-reload || true
        echo "Run 'systemctl enable --now ${NAME}' to start the daemon"
    }
}

install_init_bsd() {
    [ -d "${RCONF_DIR}" ] && [ -d "${INIT_DIR}" ] || return

    echo "Installing BSD-style init script..."
    [ -f "${RCONF_DIR}/${NAME}" ] || {
        install -m 755 kmsgd.init "${RCONF_DIR}/"
        echo "To enable and start:"
        echo "  /etc/rc.d/${NAME} enable"
        echo "  /etc/rc.d/${NAME} start"
    }
}

## MAIN
parse_args "$@"
check_root
install_files
install_init_systemd
install_init_bsd
echo "Installation complete"
