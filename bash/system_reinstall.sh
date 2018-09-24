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

isCommandExists() {
    command -v ${1} > /dev/null
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
    if ! isCommandExists skypeforlinux; then
        wget https://repo.skype.com/latest/skypeforlinux-64.deb
        dpkg -i skypeforlinux-64.deb || true
        apt install -f -y
        rm skypeforlinux-64.deb -f
    else 
        echo "Skype already installed. Continue..."
    fi
}

installTimeDoctor() {
    aptInstall libssl1.0-dev
    aptInstall libappindicator1
    if ! isCommandExists skypeforlinux; then
        wget https://updates.timedoctor.com/download/_production/tdpro/linux/timedoctor-setup-1.5.0.20-linux-x86_64.run
        chmod u+x ./timedoctor-setup-1.5.0.20-linux-x86_64.run
        ./timedoctor-setup-1.5.0.20-linux-x86_64.run
        rm timedoctor-setup-1.5.0.20-linux-x86_64.run
    else
        echo "Timedoctor already installed. Continue..."
    fi
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
    aptInstall php php-mysql php-gd php-imagick php-curl php-xml php-mbstring php-zip php-xdebug
    makeBackupIfNotExists /etc/apache2/apache2.conf
    cp ${DIR}/apache2.conf /etc/apache2/apache2.conf
    a2dissite 000-default > /dev/null
}

configurePHPIni() {
    aptInstall crudini
    # update both apache and cli php ini configs
    for php_ini in /etc/php/7.2/apache2/php.ini /etc/php/7.2/cli/php.ini; do
        makeBackupIfNotExists ${php_ini}
        crudini --set ${php_ini} PHP error_reporting E_ALL
        crudini --set ${php_ini} PHP short_open_tag On
        crudini --set ${php_ini} PHP html_errors Off
        crudini --set ${php_ini} PHP post_max_size 128M
        crudini --set ${php_ini} PHP upload_max_filesize 128M
        crudini --set ${php_ini} PHP display_errors On
        crudini --set ${php_ini} PHP display_startup_errors On
        crudini --set ${php_ini} Assertion zend.assertions 1
        crudini --set ${php_ini} PHP xdebug.remote_enable 1
    done
}

isPeclExtensionInstalled() {
    pecl list | grep ${1} > /dev/null
}

installVips() {
    aptInstall php-dev
    aptInstall libvips-dev
    if ! isPeclExtensionInstalled vips; then
        # confirm prompt 'enable vips [yes] :'
        printf "\n" | pecl install vips
        for php_ini in /etc/php/7.2/apache2/php.ini /etc/php/7.2/cli/php.ini; do
            makeBackupIfNotExists ${php_ini}
            crudini --set ${php_ini} PHP extension vips.so
        done
    else
        echo "vips already installed. Continue..."
    fi
}

installVirtHostManageScript() {
    # https://github.com/RoverWire/virtualhost
    local INSTALL_PATH='/usr/local/bin'
    wget -O ${INSTALL_PATH}/virtualhost https://raw.githubusercontent.com/RoverWire/virtualhost/master/virtualhost.sh
    chmod +x ${INSTALL_PATH}/virtualhost
    wget -O ${INSTALL_PATH}/virtualhost-nginx https://raw.githubusercontent.com/RoverWire/virtualhost/master/virtualhost-nginx.sh
    chmod +x ${INSTALL_PATH}/virtualhost-nginx
}

checkRootPerm
printCommandBeforeExecution
dieOnError

checkRootPerm;
aptInstall chromium-browser
aptInstall fish
aptInstall yakuake
aptInstall git
aptInstall mpv
aptInstall doublecmd-qt
aptInstall vim
aptInstall xclip
sudo usermod -s /usr/bin/fish ${REAL_USER}
installSkype
installTimeDoctor

installPhpAndApache
configurePHPIni
installVips
installVirtHostManageScript

service apache2 restart