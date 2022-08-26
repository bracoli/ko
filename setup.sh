#!/bin/bash
RED="\e[1;31m"
GREEN="\e[0;32m"
NC="\e[0m"
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")
#########################

clear
echo -e "${RED}Installing Some Updates On This VPS${NC}"
mkdir -p /etc/samvpn
mkdir -p /etc/samvpn/xray
mkdir -p /etc/samvpn/ntls
mkdir -p /etc/samvpn/tls
mkdir -p /etc/samvpn/config-url
mkdir -p /etc/samvpn/config-user
mkdir -p /etc/samvpn/xray/conf
mkdir -p /etc/samvpn/ntls/conf
mkdir -p /etc/systemd/system/
mkdir -p /var/log/xray/
touch /etc/samvpn/xray/user.txt

apt update -y
apt upgrade -y
apt dist-upgrade -y
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y

# install wget and curl
apt -y install wget curl

# Install Requirements Tools
apt install ruby -y
apt install python -y
apt install make -y
apt install cmake -y
apt install coreutils -y
apt install rsyslog -y
apt install net-tools -y
apt install zip -y
apt install unzip -y
apt install nano -y
apt install sed -y
apt install gnupg -y
apt install gnupg1 -y
apt install bc -y
apt install jq -y
apt install apt-transport-https -y
apt install build-essential -y
apt install dirmngr -y
apt install libxml-parser-perl -y
apt install neofetch -y
apt install git -y
apt install lsof -y
apt install libsqlite3-dev -y
apt install libz-dev -y
apt install gcc -y
apt install g++ -y
apt install libreadline-dev -y
apt install zlib1g-dev -y
apt install libssl-dev -y
apt install libssl1.0-dev -y
apt install dos2unix -y
apt-get install netfilter-persistent -y
apt-get install socat -y
apt install figlet -y
apt install git -y
clear
echo "Please Input Your Domain Name"
read -p "Input Your Domain : " host
if [ -z $host ]; then
    echo "No Domain Inserted !"
else
    echo $host >/root/domain
fi
echo -e "${RED}Installing XRAY${NC}"
sleep 2

wget https://raw.githubusercontent.com/bracoli/ko/main/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh
wget https://raw.githubusercontent.com/bracoli/ko/main/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh
cd /usr/bin
wget -O menu "https://raw.githubusercontent.com/bracoli/ko/main/xray-menu.sh" && chmod +x menu
wget -O xp "https://raw.githubusercontent.com/bracoli/ko/main/xp.sh" && chmod +x xp
timedatectl set-timezone Asia/Kuala_Lumpur
echo "0 0 * * * root xp" >>/etc/crontab
echo "1 0 * * * root systemctl restart xray.service" >>/etc/crontab
echo "1 0 * * * root systemctl restart xray@n" >>/etc/crontab
echo "1 0 * * * root systemctl restart xray.service" >>/etc/crontab
echo "0 5 * * * root reboot" >>/etc/crontab
/etc/init.d/cron restart
clear
systemctl restart nginx
cd
echo "menu" >>/root/.profile
echo " "
echo "===================-[ Multiport ]-===================="
echo ""
echo "------------------------------------------------------------"
echo ""
echo "   - OpenVPN                    : TCP 1194, UDP 2200, SSL 442" | tee -a log-install.txt
echo "   - Stunnel4                   : 789, 777" | tee -a log-install.txt
echo "   - Squid Proxy                : 3128, 8080" | tee -a log-install.txt
echo "   - VLess TCP XTLS             : 443" | tee -a log-install.txt
echo "   - XRAY  Trojan TLS           : 443" | tee -a log-install.txt
echo "   - XRAY  Vmess TLS            : 443" | tee -a log-install.txt
echo "   - XRAY  Vmess None TLS       : 80" | tee -a log-install.txt
echo "   - XRAY  Vless TLS            : 443" | tee -a log-install.txt
echo "   - XRAY  Vless None TLS       : 8000" | tee -a log-install.txt
echo ""
echo "------------------------------------------------------------"
echo ""
echo "===================-[ Multiport ]-===================="
echo ""
rm -f /root/ins-xray.sh
rm -f /root/setup.sh
read -n 1 -s -r -p "Press any key to reboot"
reboot
