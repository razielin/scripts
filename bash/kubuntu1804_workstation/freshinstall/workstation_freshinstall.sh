#!/usr/bin/env bash
REAL_USER=`logname`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )" # script dir

main() {
    printFunctionNameBeforeExecution

    checkRootPerm
    dieOnError
    cd `mktemp --directory`

    apt update
    apt upgrade -y
    aptInstall chromium-browser

    installTimeDoctor
    installSkype
    installLibreOffice

    installEarlyOom

    addCronJobsOnStartup

    configureAutoupgrade
    configurePrinter
    configureKeyboardLayoutSwitching
    setDefaultBrowser
}

printFunctionNameBeforeExecution() {
    trap 'echoCommand' DEBUG > /dev/null
}

echoCommand() {
    local YELLOW='\033[0;33m'
    local NC='\033[0m' # No Color
    echo -e "$YELLOW>>> $BASH_COMMAND$NC"
}

xtraceCommandPrintBeforeExecution() {
    export PS4='\[\e[36m\] + \[\e[m\]'
    set -o xtrace
}

checkRootPerm() {
    if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root" 1>&2
       exit 1
    fi
}

dieOnError() {
    set -e
}

commandExists() {
    command -v ${1} > /dev/null
}

setIniVar() {
    local var=$1
    local value=$2
    local file=$3
    sed -Ei "s/;?\s*($var)\s*=\s*(.*)/\1 = $value/g" ${file}
}

aptInstall() {
    apt-get install -y ${@}
}

debInstallByUrl() {
    url="$1"
    filename=`basename "$1"`
    wget --content-disposition ${1}
    dpkg -i ${filename} || true # if there are unresolved dependencies - force successful status code
    apt install -f -y # fix unresolved dependencies if any
    rm ${filename} -f
}

debInstall() {
    file=$1
    dpkg -i ${file} || true
    apt install -f -y
}

installSkype() {
    if ! commandExists skypeforlinux; then
        debInstallByUrl "https://repo.skype.com/latest/skypeforlinux-64.deb"
    else
        echo "Skype already installed. Continue..."
    fi
}

installTimeDoctor() {
    aptInstall libssl1.0-dev
    aptInstall libappindicator1
    if ! commandExists skypeforlinux; then
        wget https://updates.timedoctor.com/download/_production/tdpro/linux/timedoctor-setup-1.5.0.20-linux-x86_64.run
        chmod u+x ./timedoctor-setup-1.5.0.20-linux-x86_64.run
        ./timedoctor-setup-1.5.0.20-linux-x86_64.run
        rm timedoctor-setup-1.5.0.20-linux-x86_64.run
    else
        echo "Timedoctor already installed. Continue..."
    fi
}

configureAutoupgrade() {
    aptInstall unattended-upgrades
    cp "$DIR/20auto-upgrades" /etc/apt/apt.conf.d/20auto-upgrades
    cp "$DIR/50unattended-upgrades" /etc/apt/apt.conf.d/50unattended-upgrades
    unattended-upgrades --debug
}

setDefaultBrowser() {
    update-alternatives --config x-www-browser
}

makeBackupIfNotExists() {
    local file=$1
    local SUFFIX="default"
    # if backup file is not exists
    if [[ ! -e ${file}.${SUFFIX} ]]; then
        cp ${file} ${file}.${SUFFIX}
    fi
}

addCronJobsOnStartup() {
    # fix timedoctor bug with unlimited growing log file which causes slow timedoctor start time
    echo "@reboot bash -c 'rm /home/*/.local/share/TimeDoctorLLC/TimeDoctorPro/log.db'" | crontab -
}

installEarlyOom() {
    aptInstall earlyoom
    cp "$DIR/earlyoom" /etc/default/earlyoom
    systemctl restart earlyoom
}

configurePrinter() {
    service cups stop
    cp "$DIR/printers.conf" /etc/cups/printers.conf
    service cups start
}

installLibreOffice() {
    aptInstall libreoffice libreoffice-kde libreoffice-l10n-ru libreoffice-help-ru libreoffice-pdfimport hunspell-ru libreoffice-grammarcheck-ru
}

configureKeyboardLayoutSwitching() {
    mkdir -p /etc/X11/xorg.conf.d
    cp "$DIR/00-keyboard.conf" /etc/X11/xorg.conf.d/00-keyboard.conf
}

main