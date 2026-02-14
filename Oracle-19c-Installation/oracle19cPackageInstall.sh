#!/bin/bash

set -uo pipefail   # Removed -e

LOG_FILE="/scripts/log/oracle19cPackageInstall_$(date +%Y%m%d_%H%M%S).log"
exec >> "$LOG_FILE" 2>&1

FAILED_PACKAGES=()

install_packages() {

    echo "Starting package installation at $(date)"
    echo "--------------------------------------------"

    packages=(
        bc    
        binutils
        compat-libcap1
        compat-libstdc++-33
        dtrace-utils
        elfutils-libelf
        elfutils-libelf-devel
        fontconfig-devel
        glibc
        glibc-devel
        ksh
        libaio
        libaio-devel
        libdtrace-ctf-devel
        libXrender
        libXrender-devel
        libX11
        libXau
        libXi
        libXtst
        libgcc
        librdmacm-devel
        libstdc++
        libstdc++-devel
        libxcb
        make
        net-tools # Clusterware
        nfs-utils # ACFS
        python # ACFS
        python-configshell # ACFS
        python-rtslib # ACFS
        python-six # ACFS
        targetcli # ACFS
        smartmontools
        sysstat
        gcc
        unixODBC
    )

    for pkg in "${packages[@]}"; do
        echo "Installing $pkg ..."
        
        if yum install -y "$pkg"; then
            echo "$pkg installed successfully."
        else
            echo "WARNING: Failed to install $pkg"
            FAILED_PACKAGES+=("$pkg")
        fi
    done

    echo "Installing xorg packages..."
    if yum install -y "xorg*"; then
        echo "xorg packages installed successfully."
    else
        echo "WARNING: Failed to install xorg packages"
        FAILED_PACKAGES+=("xorg*")
    fi

    echo "--------------------------------------------"
    echo "Installation completed at $(date)"

    if [ ${#FAILED_PACKAGES[@]} -ne 0 ]; then
        echo "The following packages failed:"
        for failed in "${FAILED_PACKAGES[@]}"; do
            echo " - $failed"
        done
    else
        echo "All packages installed successfully."
    fi
}

main() {
    echo "Script started at $(date)"
    install_packages
    echo "Script completed at $(date)"
}

main
