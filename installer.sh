#!/bin/bash

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

echo -e "$Green \n Installing Package $Color_Off"

apt-get update
apt-get install -y sudo
sudo apt-get update
sudo apt-get install -y net-tools 
sudo apt-get install -y openssh-server
sudo apt-get install -y ssh
sudo apt-get install -y wget
sudo apt-get install -y usb-modeswitch-data
sudo apt-get install -y usb-modeswitch 
sudo apt-get install -y usbutils 
sudo apt-get install -y usbview
sudo apt-get install -y ifplugd
sudo apt-get install -y parallel
sudo apt-get install -y snmpd
sudo apt-get install -y openssl
sudo apt-get install -y easy-rsa
sudo apt-get install -y openvpn
sudo apt-get install -y dnsmasq
sudo apt-get install -y collectd
sudo apt-get install -y libsodium-dev
sudo apt-get install -y git
sudo apt-get install -y ca-certificates
sudo apt-get install -y build-essential
sudo apt-get install -y pkg-config
sudo apt-get install -y hostapd
sudo apt-get install -y dnsmasq
sudo apt-get install -y wireless-tools
sudo apt-get install -y iw
sudo apt-get install -y wvdial
sudo apt-get install -y aptitude
sudo apt-get install -y lshw
sudo apt-get install -y ipcalc
sudo apt-get install -y ifplugd
sudo apt-get install -y parallel
sudo apt-get install -y ifstat
sudo apt-get install -y php-ssh2
sudo apt-get install -y firmware-misc-nonfree
sudo apt-get install -y gnupg2
sudo apt-get install -y curl
sudo apt-get install -y wget
sudo apt-get install -y software-properties-common
sudo apt-get install -y git
sudo apt-get install -y autoconf
sudo apt-get install -y automake 
sudo apt-get install -y libtool
sudo apt-get install -y make 
sudo apt-get install -y libreadline-dev
sudo apt-get install -y texinfo
sudo apt-get install -y libjson-c-dev 
sudo apt-get install -y pkg-config
sudo apt-get install -y bison
sudo apt-get install -y flex 
sudo apt-get install -y libc-ares-dev 
sudo apt-get install -y python3-dev
sudo apt-get install -y python3-pytest
sudo apt-get install -y python3-sphinx
sudo apt-get install -y build-essential 
sudo apt-get install -y libsnmp-dev
sudo apt-get install -y libsystemd-dev
sudo apt-get install -y libcap-dev
sudo apt-get install -y iptables
sudo apt-get install -y arptables
sudo apt-get install -y ebtables

echo -e "$Cyan \n Installing PHP $Color_Off"

sudo apt -y install lsb-release apt-transport-https ca-certificates 
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list

sudo apt update

sudo apt -y install php7.4

sudo apt-get install -y php7.4-{bcmath,bz2,intl,gd,mbstring,mysql,zip,curl} 

echo -e "$Cyan \n Installing MYSQl-Maria $Color_Off"

sudo apt -y install mariadb-server mariadb-client

echo -e "$Cyan \n Installing InfluxDB $Color_Off"

wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
echo "deb https://repos.influxdata.com/debian buster stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt update
sudo apt install -y influxdb

echo -e "$Cyan \n Installing FRRouting $Color_Off"

# add GPG key
curl -s https://deb.frrouting.org/frr/keys.asc | sudo apt-key add -

# possible values for FRRVER: frr-6 frr-7 frr-stable
# frr-stable will be the latest official stable release
FRRVER="frr-stable"
echo deb https://deb.frrouting.org/frr $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list

# update and install FRR
sudo apt update && sudo apt install -y frr frr-pythontools