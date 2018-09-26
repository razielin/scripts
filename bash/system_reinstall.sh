#!/usr/bin/env bash
REAL_USER=`logname`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )" # script dir

main() {
    printFunctionNameBeforeExecution

    checkRootPerm
    printCommandBeforeExecution
    dieOnError

    aptInstall chromium-browser
    aptInstall fish
    aptInstall yakuake
    aptInstall git
    aptInstall mpv
    aptInstall doublecmd-qt
    aptInstall vim curl
    aptInstall xclip
    aptInstall keepassxc

    sudo usermod -s /usr/bin/fish ${REAL_USER}

    installSkype
    installTimeDoctor
    installDropbox

    installPhpAndApache
    installVips
    installVirtHostManageScript
    installMariadb
    installPhpMyAdmin

    configurePHPIni

    service apache2 restart
    service mariadb restart
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

printCommandBeforeExecution() {
    set -v
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
    apt install ${@}
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
    # update all installed php.ini files
    PHP_VERSION=`php -r "echo PHP_VERSION;" | cut -c 1,2,3` # php version, like 5.6
    for php_type in apache2 cli fpm; do
        local php_ini="/etc/php/$PHP_VERSION/$php_type/php.ini"
        if [ -e ${php_ini} ]; then
            echo "Updating php.ini: $php_ini"
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
        fi
    done
}

peclExtensionInstalled() {
    extensionName=$1
    pecl list | grep ${extensionName} > /dev/null
}

installVips() {
    if ! peclExtensionInstalled vips; then
        # php-dev conflicts with Timedoctor, because Timedoctor requires libssl1.0-dev but php-dev requires libssl-dev
        # so during installation of php-dev - libssl1.0-dev will be removed and timedoctor will not sync
        aptInstall php-dev # required by pecl install vips
        aptInstall libvips-dev
        # confirm prompt 'enable vips [yes] :'
        printf "\n" | pecl install vips
        for php_ini in /etc/php/7.2/apache2/php.ini /etc/php/7.2/cli/php.ini; do
            makeBackupIfNotExists ${php_ini}
            crudini --set ${php_ini} PHP extension vips.so
        done
    else
        echo "vips already installed. Continue..."
    fi
    # reinstall libssl1.0-dev to fix Timedoctor
    aptInstall libssl1.0-dev
}

installVirtHostManageScript() {
    # https://github.com/RoverWire/virtualhost
    local INSTALL_PATH='/usr/local/bin'
    wget -O ${INSTALL_PATH}/virtualhost https://raw.githubusercontent.com/RoverWire/virtualhost/master/virtualhost.sh
    chmod +x ${INSTALL_PATH}/virtualhost
    wget -O ${INSTALL_PATH}/virtualhost-nginx https://raw.githubusercontent.com/RoverWire/virtualhost/master/virtualhost-nginx.sh
    chmod +x ${INSTALL_PATH}/virtualhost-nginx
}

installMariadb() {
    DB_ADMIN_USER='raziel'
    DB_ADMIN_PASS='556691'

    if ! commandExists mariadb; then
        aptInstall mariadb-server mariadb-client
        mysql_secure_installation
        echo "
        CREATE USER '$DB_ADMIN_USER'@'localhost' IDENTIFIED BY '$DB_ADMIN_PASS';
        GRANT ALL PRIVILEGES ON * . * TO '$DB_ADMIN_USER'@'localhost';
        FLUSH PRIVILEGES;
        " | mysql -u root
    else
        echo "mariadb already installed. Continue..."
    fi
}

installPhpMyAdmin() {
    aptInstall phpmyadmin php-mbstring php-gettext
    phpenmod mbstring
    service apache2 restart
}

installDocker() {
    if ! commandExists docker; then
        aptInstall apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
        apt update
        apt install docker-ce
        usermod -aG docker ${REAL_USER}
    else
        echo "docker already installed. Continue..."
    fi
}

installDropbox() {
    if ! commandExists dropbox; then
        debInstallByUrl "https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2015.10.28_amd64.deb"
    else
        echo "dropbox already installed. Continue..."
    fi
}

main