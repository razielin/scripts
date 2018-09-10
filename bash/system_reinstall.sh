#!/usr/bin/env bash
REAL_USER=`logname`

checkRootPerm() {
    if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root" 1>&2
       exit 1
    fi
}

aptInstall() {
    apt install $1 -y
}

installSkype() {
    wget https://repo.skype.com/latest/skypeforlinux-64.deb
    dpkg -i skypeforlinux-64.deb
    apt install -f
    rm skypeforlinux-64.deb -f
}

checkRootPerm;
aptInstall chromium-browser
aptInstall fish
aptInstall guake
aptInstall git
sudo usermod -s /usr/bin/fish ${REAL_USER}
installSkype


