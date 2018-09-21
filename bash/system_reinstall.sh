#!/usr/bin/env bash
REAL_USER=`logname`

checkRootPerm() {
    if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root" 1>&2
       exit 1
    fi
}

dieOnError() {
    set -e
}

printCommandBeforeExecution() {
    set -v
}

setIniVar() {
    local var=$1
    local value=$2
    local file=$3
    sed -Ei "s/;?\s*($var)\s*=\s*(.*)/\1 = $value/mg" ${file}
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

installTimeDoctor() {
    aptInstall libssl1.0-dev
    aptInstall libappindicator1
    wget https://updates.timedoctor.com/download/_production/tdpro/linux/timedoctor-setup-1.5.0.20-linux-x86_64.run
    ./timedoctor-setup-1.5.0.20-linux-x86_64.run
    rm timedoctor-setup-1.5.0.20-linux-x86_64.run
}

checkRootPerm
aptInstall chromium-browser
aptInstall fish
aptInstall guake
aptInstall git
sudo usermod -s /usr/bin/fish ${REAL_USER}
installSkype
installTimeDoctor
