#!/usr/bin/env bash
REAL_USER=`logname`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )" # script dir

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
    sed -Ei "s/;?\s*($var)\s*=\s*(.*)/\1 = $value/g" ${file}
}

aptInstall() {
    apt install ${@} -y
}

installSkype() {
    wget https://repo.skype.com/latest/skypeforlinux-64.deb
    dpkg -i skypeforlinux-64.deb || true
    apt install -f
    rm skypeforlinux-64.deb -f
}

installTimeDoctor() {
    aptInstall libssl1.0-dev
    aptInstall libappindicator1
    wget https://updates.timedoctor.com/download/_production/tdpro/linux/timedoctor-setup-1.5.0.20-linux-x86_64.run
    chmod u+x ./timedoctor-setup-1.5.0.20-linux-x86_64.run
    ./timedoctor-setup-1.5.0.20-linux-x86_64.run
    rm timedoctor-setup-1.5.0.20-linux-x86_64.run
}

installPHPStorm() {
    snap install phpstorm --channel=2018.3/edge --classic
}

makeBackupIfNotExists() {
    local file=$1
    local SUFFIX="default"
    # if backup file is not exists
    if [ ! -e ${file}.${SUFFIX} ]; then
        cp ${file} ${file}.${SUFFIX}
    fi
}

installPhpAndApache() {
    aptInstall php php-mysql php-gd php-imagick php-curl php-xml php-mbstring php-zip
    makeBackupIfNotExists /etc/apache2/apache2.conf
    cp ${DIR}/apache2.conf /etc/apache2/apache2.conf
}

configurePHPIni() {
    aptInstall crudini
    # update both apache and cli php ini configs
    for php_ini in /etc/php/7.2/apache2/php.ini /etc/php/7.2/cli/php.ini; do
        crudini --set ${php_ini} PHP error_reporting E_ALL
        crudini --set ${php_ini} PHP short_open_tag On
        crudini --set ${php_ini} PHP html_errors Off
        crudini --set ${php_ini} PHP post_max_size 128M
        crudini --set ${php_ini} PHP upload_max_filesize 128M
        crudini --set ${php_ini} Assertion zend.assertions 1
        crudini --set ${php_ini} Assertion display_errors On
        crudini --set ${php_ini} Assertion display_startup_errors On
    done
}

checkRootPerm
printCommandBeforeExecution
dieOnError

aptInstall chromium-browser
aptInstall fish
aptInstall yakuake
aptInstall git
aptInstall mpv
aptInstall doublecmd-qt
aptInstall vim
sudo usermod -s /usr/bin/fish ${REAL_USER}
installSkype
installTimeDoctor
