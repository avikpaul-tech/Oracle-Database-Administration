#!/bin/bash

set -euo pipefail

LOG_FILE="/scripts/log/oracle-database-preinstall-19c_$(date +%Y%m%d_%H%M%S).log"
exec >> "$LOG_FILE" 2>&1

error_exit() {
    echo "ERROR: $1"
    exit 1
}

install_preinstall_package() {
    echo "Installing package..."
    yum install -y oracle-database-preinstall-19c || error_exit "Installation failed"
}

main() {
    echo "Script started at $(date)"
    install_preinstall_package
    echo "Script completed at $(date)"
}

main   # <-- This acts like entry point
