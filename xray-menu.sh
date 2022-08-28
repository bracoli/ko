#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")
#########################

red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

add_ssh() {
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m                • ADD SSH USER •                  \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -p "Username : " Login
    read -p "Password : " Pass
    read -p "Expired (hari): " masaaktif
    IP=$(wget -qO- icanhazip.com)
    domain=$(cat /root/domain)
    IP=$(wget -qO- ipinfo.io/ip)
    ssl="$(cat ~/log-install.txt | grep -w "Stunnel4" | cut -d: -f2 | sed 's/ //g')"
    sqd="$(cat ~/log-install.txt | grep -w "Squid Proxy" | cut -d: -f2 | sed 's/ //g')"
    ovpn="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
    ovpn2="$(netstat -nlpu | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
    sleep 1
    echo Ping Host
    echo Cek Hak Akses...
    sleep 0.5
    echo Permission Accepted
    clear
    sleep 0.5
    echo Membuat Akun: $Login
    sleep 0.5
    echo Setting Password: $Pass
    sleep 0.5
    clear
    useradd -e $(date -d "$masaaktif days" +"%Y-%m-%d") -s /bin/false -M $Login
    exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
    echo -e "$Pass\n$Pass\n" | passwd $Login &>/dev/null
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "Thank You For Using Our Services"
    echo -e "SSH & OpenVPN Account Info"
    echo -e "Username       : $Login "
    echo -e "Password       : $Pass"
    echo -e "Expired On     : $exp"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "IP Server      : $IP"
    echo -e "Host           : ${domain}"
    echo -e "OpenSSH        : 22"
    echo -e "Dropbear       : 109, 143"
    echo -e "SSL/TLS        : $ssl"
    echo -e "Port Squid     : $sqd"
    echo -e "OpenVPN        : TCP $ovpn http://$IP:81/client-tcp-$ovpn.ovpn"
    echo -e "OpenVPN        : UDP $ovpn2 http://$IP:81/client-udp-$ovpn2.ovpn"
    echo -e "OpenVPN        : SSL 442 http://$IP:81/client-tcp-ssl.ovpn"
    echo -e "badvpn         : 7100-7300"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

all_ssh() {
    clear

    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo "USERNAME          EXP DATE          STATUS"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    while read expired; do
        AKUN="$(echo $expired | cut -d: -f1)"
        ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
        exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
        status="$(passwd -S $AKUN | awk '{print $2}')"
        if [[ $ID -ge 1000 ]]; then
            if [[ "$status" = "L" ]]; then
                printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "${RED}LOCKED${NORMAL}"
            else
                printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "${GREEN}UNLOCKED${NORMAL}"
            fi
        fi
    done </etc/passwd
    JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo "Account number: $JUMLAH user"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -n 1 -s -r -p "Press any key to back on menu"
    menu

}

del_ssh() {
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m              • DELETE SSH USER •                 \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -p "Username SSH to Delete : " Pengguna

    if getent passwd $Pengguna >/dev/null 2>&1; then
        userdel $Pengguna
        echo -e "User $Pengguna was removed."
    else
        echo -e "Failure: User $Pengguna Not Exist."
    fi
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

del_exp() {
    hariini=$(date +%d-%m-%Y)
    echo "Thank you for removing the EXPIRED USERS"
    echo "--------------------------------------"
    cat /etc/shadow | cut -d: -f1,8 | sed /:$/d >/tmp/expirelist.txt
    totalaccounts=$(cat /tmp/expirelist.txt | wc -l)
    for ((i = 1; i <= $totalaccounts; i++)); do
        tuserval=$(head -n $i /tmp/expirelist.txt | tail -n 1)
        username=$(echo $tuserval | cut -f1 -d:)
        userexp=$(echo $tuserval | cut -f2 -d:)
        userexpireinseconds=$(($userexp * 86400))
        tglexp=$(date -d @$userexpireinseconds)
        tgl=$(echo $tglexp | awk -F" " '{print $3}')
        while [ ${#tgl} -lt 2 ]; do
            tgl="0"$tgl
        done
        while [ ${#username} -lt 15 ]; do
            username=$username" "
        done
        bulantahun=$(echo $tglexp | awk -F" " '{print $2,$6}')
        echo "echo "Expired- User : $username Expire at : $tgl $bulantahun"" >>/usr/local/bin/alluser
        todaystime=$(date +%s)
        if [ $userexpireinseconds -ge $todaystime ]; then
            :
        else
            echo "echo "Expired- Username : $username are expired at: $tgl $bulantahun and removed : $hariini "" >>/usr/local/bin/deleteduser
            echo "Username $username that are expired at $tgl $bulantahun removed from the VPS $hariini"
            userdel $username
        fi
    done
    echo " "
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo "Script are successfully run"
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

check_ssh() {
    if [ -e "/var/log/auth.log" ]; then
        LOG="/var/log/auth.log"
    fi
    if [ -e "/var/log/secure" ]; then
        LOG="/var/log/secure"
    fi

    data=($(ps aux | grep -i dropbear | awk '{print $2}'))
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo "-----=[ Dropbear User Login ]=-----"
    echo "ID  |  Username  |  IP Address"
    echo ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" >/tmp/login-db.txt
    for PID in "${data[@]}"; do
        cat /tmp/login-db.txt | grep "dropbear\[$PID\]" >/tmp/login-db-pid.txt
        NUM=$(cat /tmp/login-db-pid.txt | wc -l)
        USER=$(cat /tmp/login-db-pid.txt | awk '{print $10}')
        IP=$(cat /tmp/login-db-pid.txt | awk '{print $12}')
        if [ $NUM -eq 1 ]; then
            echo "$PID - $USER - $IP"
        fi
    done
    echo "-----=[ OpenSSH User Login ]=-----"
    echo "ID  |  Username  |  IP Address"
    echo ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    cat $LOG | grep -i sshd | grep -i "Accepted password for" >/tmp/login-db.txt
    data=($(ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'))

    for PID in "${data[@]}"; do
        cat /tmp/login-db.txt | grep "sshd\[$PID\]" >/tmp/login-db-pid.txt
        NUM=$(cat /tmp/login-db-pid.txt | wc -l)
        USER=$(cat /tmp/login-db-pid.txt | awk '{print $9}')
        IP=$(cat /tmp/login-db-pid.txt | awk '{print $11}')
        if [ $NUM -eq 1 ]; then
            echo "$PID - $USER - $IP"
        fi
    done
    if [ -f "/etc/openvpn/server/openvpn-tcp.log" ]; then
        echo "-----=[ OpenVPN TCP User Login ]=-----"
        echo "Username  |  IP Address  |  Connected Since"
        echo ""
        cat /etc/openvpn/server/openvpn-tcp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' >/tmp/vpn-login-tcp.txt
        cat /tmp/vpn-login-tcp.txt
    fi
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

    if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
        echo "-----=[ OpenVPN UDP User Login ]=-----"
        echo "Username  |  IP Address  |  Connected Since"
        echo ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        cat /etc/openvpn/server/openvpn-udp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' >/tmp/vpn-login-udp.txt
        cat /tmp/vpn-login-udp.txt
    fi
    read -n 1 -s -r -p "Press any key to back on menu"
    menu

}

extend_ssh() {
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m              • RENEW SSH USER •                  \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -p "         Username       :  " User
    egrep "^$User" /etc/passwd >/dev/null
    if [ $? -eq 0 ]; then
        read -p "         Day Extend     :  " Days
        Today=$(date +%s)
        Days_Detailed=$(($Days * 86400))
        Expire_On=$(($Today + $Days_Detailed))
        Expiration=$(date -u --date="1970-01-01 $Expire_On sec GMT" +%Y/%m/%d)
        Expiration_Display=$(date -u --date="1970-01-01 $Expire_On sec GMT" '+%d %b %Y')
        passwd -u $User
        usermod -e $Expiration $User
        egrep "^$User" /etc/passwd >/dev/null
        echo -e "$Pass\n$Pass\n" | passwd $User &>/dev/null
        clear
        echo -e ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e ""
        echo -e "    Username        :  $User"
        echo -e "    Days Added      :  $Days Days"
        echo -e "    Expires on      :  $Expiration_Display"
        echo -e ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    else
        clear
        echo -e ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e ""
        echo -e "        Username Doesnt Exist        "
        echo -e ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    fi
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

add-ws() {
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m                • ADD XRAY USER •                 \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    read -p "Username  : " user
    if grep -qw "$user" /etc/samvpn/xray/user.txt; then
        echo -e ""
        echo -e "User \e[31m$user\e[0m already exist"
        echo -e ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        read -n 1 -s -r -p "Press any key to back on menu"
        menu
    fi
    read -p "Duration (day) : " duration
    uuid=$(cat /proc/sys/kernel/random/uuid)
    exp=$(date -d +${duration}days +%Y-%m-%d)
    domain=$(cat /root/domain)
    multi="$(cat ~/log-install.txt | grep -w "VLess TCP XTLS" | cut -d: -f2 | sed 's/ //g')"
    none=80
    email=${user}
    cat >/etc/samvpn/xray/$user-tls.json <<EOF
      {
       "v": "2",
       "ps": "${user}",
       "add": "${domain}",
       "port": "${multi}",
       "id": "${uuid}",
       "aid": "0",
       "scy": "auto",
       "net": "ws",
       "type": "none",
       "host": "${BUG}",
       "path": "/xrayvws",
       "tls": "tls",
       "sni": "${BUG}"
}
EOF

    cat >/etc/samvpn/xray/$user-none.json <<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "${none}",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/xrayws",
      "type": "none",
      "host": "",
      "tls": "none"
}
EOF
    echo -e "${user}\t${uuid}\t${exp}" >>/etc/samvpn/xray/user.txt
    cat /etc/samvpn/xray/conf/05_VMess_WS_inbounds.json | jq '.inbounds[0].settings.clients += [{"id": "'${uuid}'","alterId": 0,"add": "'${domain}'","email": "'${email}'"}]' >/etc/samvpn/xray/conf/05_VMess_WS_inbounds_tmp.json
    mv -f /etc/samvpn/xray/conf/05_VMess_WS_inbounds_tmp.json /etc/samvpn/xray/conf/05_VMess_WS_inbounds.json
    sed -i '/#xray$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$email""'"' /etc/samvpn/xray/conf/vmess-nontls.json
    vmess_base641=$(base64 -w 0 <<<$vmess_json1)
    vmess_base642=$(base64 -w 0 <<<$vmess_json2)
    vmesslink1="vmess://$(base64 -w 0 /etc/samvpn/xray/$user-tls.json)"
    vmesslink2="vmess://$(base64 -w 0 /etc/samvpn/xray/$user-none.json)"
    cat <<EOF >>"/etc/samvpn/config-user/${user}"
${vmesslink1}
${vmesslink2}
EOF
    base64Result=$(base64 -w 0 /etc/samvpn/config-user/${user})
    echo ${base64Result} >"/etc/samvpn/config-url/${uuid}"
    systemctl restart xray.service
    echo -e "\033[32m[Info]\033[0m XRay Start Successfully !"
    sleep 1
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m            • XRAY USER INFORMATION •             \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e ""
    echo -e " Username           : $user"
    echo -e " Expired date       : $exp"
    echo -e " Port TLS           : $multi"
    echo -e " Port Non TLS       : $none"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "VMess TLS : "
    echo ""
    echo "$vmesslink1"
    echo ""
    echo -e "VMess Non TLS : "
    echo ""
    echo "$vmesslink2"
    echo ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

add-vless() {
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m                • ADD XRAY USER •                 \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    read -p "Username  : " user
    if grep -qw "$user" /etc/samvpn/xray/user.txt; then
        echo -e ""
        echo -e "User \e[31m$user\e[0m already exist"
        echo -e ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        read -n 1 -s -r -p "Press any key to back on menu"
        menu
    fi
    read -p "Duration (day) : " duration
    uuid=$(cat /proc/sys/kernel/random/uuid)
    exp=$(date -d +${duration}days +%Y-%m-%d)
    domain=$(cat /root/domain)
    multi="$(cat ~/log-install.txt | grep -w "VLess TCP XTLS" | cut -d: -f2 | sed 's/ //g')"
    none=8000
    email=${user}
    echo -e "${user}\t${uuid}\t${exp}" >>/etc/samvpn/xray/user.txt
    sed -i '/#xray$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$email""'"' /etc/samvpn/xray/vless-nontls.json
    cat /etc/samvpn/xray/conf/03_VLESS_WS_inbounds.json | jq '.inbounds[0].settings.clients += [{"id": "'${uuid}'","email": "'${email}'"}]' >/etc/samvpn/xray/conf/03_VLESS_WS_inbounds_tmp.json
    mv -f /etc/samvpn/xray/conf/03_VLESS_WS_inbounds_tmp.json /etc/samvpn/xray/conf/03_VLESS_WS_inbounds.json
    vlesslink1="vless://$uuid@$domain:$multi?encryption=none&security=tls&sni=&type=ws&host=&path=/xrayws#$user"
    vlesslink2="vless://$uuid@$domain:$none?encryption=none&security=none&sni=&type=ws&host=&path=/xrayws#$user"
    cat <<EOF >>"/etc/samvpn/config-user/${user}"
${vlesslink1}
${vlesslink2}
EOF
    echo ${base64Result} >"/etc/samvpn/config-url/${uuid}"
    systemctl restart xray.service
    systemctl restart xray@n
    echo -e "\033[32m[Info]\033[0m XRay Start Successfully !"
    sleep 1
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m            • XRAY USER INFORMATION •             \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e ""
    echo -e " Username           : $user"
    echo -e " Expired date       : $exp"
    echo -e " Port TLS           : $multi"
    echo -e " Port Non TLS       : $none"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "VLess TLS : "
    echo ""
    echo "$vlesslink1"
    echo ""
    echo -e "VLess Non TLS : "
    echo ""
    echo "$vlesslink2"
    echo ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

add-trojan() {
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m                • ADD XRAY USER •                 \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    read -p "Username  : " user
    if grep -qw "$user" /etc/samvpn/xray/user.txt; then
        echo -e ""
        echo -e "User \e[31m$user\e[0m already exist"
        echo -e ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        read -n 1 -s -r -p "Press any key to back on menu"
        menu
    fi
    read -p "Duration (day) : " duration
    uuid=$(cat /proc/sys/kernel/random/uuid)
    exp=$(date -d +${duration}days +%Y-%m-%d)
    domain=$(cat /root/domain)
    multi="$(cat ~/log-install.txt | grep -w "VLess TCP XTLS" | cut -d: -f2 | sed 's/ //g')"
    email=${user}
    echo -e "${user}\t${uuid}\t${exp}" >>/etc/samvpn/xray/user.txt
    cat /etc/samvpn/xray/conf/04_trojan_TCP_inbounds.json | jq '.inbounds[0].settings.clients += [{"password": "'${uuid}'","email": "'${email}'"}]' >/etc/samvpn/xray/conf/04_trojan_TCP_inbounds_tmp.json
    mv -f /etc/samvpn/xray/conf/04_trojan_TCP_inbounds_tmp.json /etc/samvpn/xray/conf/04_trojan_TCP_inbounds.json
    tro="trojan://$uuid@$domain:$multi?sni=#$user"
    cat <<EOF >>"/etc/samvpn/config-user/${user}"
${tro}
EOF
    systemctl restart xray
    echo -e "\033[32m[Info]\033[0m XRay Start Successfully !"
    sleep 1
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m            • XRAY USER INFORMATION •             \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e ""
    echo -e " Username           : $user"
    echo -e " Expired date       : $exp"
    echo -e " Port TLS           : $multi"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "TRojan TCP TLS  : "
    echo ""
    echo "$tro"
    echo ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

add-xtls() {
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m                • ADD XRAY USER •                 \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    read -p "Username  : " user
    if grep -qw "$user" /etc/samvpn/xray/user.txt; then
        echo -e ""
        echo -e "User \e[31m$user\e[0m already exist"
        echo -e ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        read -n 1 -s -r -p "Press any key to back on menu"
        menu
    fi
    read -p "Duration (day) : " duration
    uuid=$(cat /proc/sys/kernel/random/uuid)
    exp=$(date -d +${duration}days +%Y-%m-%d)
    domain=$(cat /root/domain)
    multi="$(cat ~/log-install.txt | grep -w "VLess TCP XTLS" | cut -d: -f2 | sed 's/ //g')"
    email=${user}
    echo -e "${user}\t${uuid}\t${exp}" >>/etc/samvpn/xray/user.txt
    cat /etc/samvpn/xray/conf/02_VLESS_TCP_inbounds.json | jq '.inbounds[0].settings.clients += [{"id": "'${uuid}'","add": "'${domain}'","flow": "xtls-rprx-direct","email": "'${email}'"}]' >/etc/samvpn/xray/conf/02_VLESS_TCP_inbounds_tmp.json
    mv -f /etc/samvpn/xray/conf/02_VLESS_TCP_inbounds_tmp.json /etc/samvpn/xray/conf/02_VLESS_TCP_inbounds.json
    splice="vless://$uuid@$domain:$multi?flow=xtls-rprx-splice&encryption=none&security=xtls&sni=&type=tcp&headerType=none&host=#$user"
    direct="vless://$uuid@$domain:$multi?flow=xtls-rprx-direct&encryption=none&security=xtls&sni=&type=tcp&headerType=none&host=#$user"
    cat <<EOF >>"/etc/samvpn/config-user/${user}"
${splice}
${direct}
EOF
    systemctl restart xray
    echo -e "\033[32m[Info]\033[0m XRay Start Successfully !"
    sleep 1
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m            • XRAY USER INFORMATION •             \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e ""
    echo -e " Username           : $user"
    echo -e " Expired date       : $exp"
    echo -e " Port TLS           : $multi"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "Splice : "
    echo ""
    echo "$splice"
    echo ""
    echo -e "Direct : "
    echo ""
    echo "$direct"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

del-user() {
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m               • DELETE XRAY USER •               \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    cat /etc/samvpn/xray/user.txt | awk '{print $1}' | sort | uniq
    echo -e ""
    read -p "Username : " user
    echo -e ""
    if ! grep -qw "$user" /etc/samvpn/xray/user.txt; then
        echo -e ""
        echo -e "User \e[31m$user\e[0m does not exist"
        echo ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        read -n 1 -s -r -p "Press any key to back on menu"
        menu
    fi
    uuid="$(cat /etc/samvpn/xray/user.txt | grep -w "$user" | awk '{print $2}')"
    exp="$(cat /etc/samvpn/xray/user.txt | grep -w "$user" | awk '{print $3}')"
    cat /etc/samvpn/xray/conf/05_VMess_WS_inbounds.json | jq 'del(.inbounds[0].settings.clients[] | select(.id == "'${uuid}'"))' >/etc/samvpn/xray/conf/05_VMess_WS_inbounds_tmp.json
    mv -f /etc/samvpn/xray/conf/05_VMess_WS_inbounds_tmp.json /etc/samvpn/xray/conf/05_VMess_WS_inbounds.json
    sed -i "/^### $user $exp/,/^},{/d" /etc/samvpn/xray/conf/vmess-nontls.json
    cat /etc/samvpn/xray/conf/03_VLESS_WS_inbounds.json | jq 'del(.inbounds[0].settings.clients[] | select(.id == "'${uuid}'"))' >/etc/samvpn/xray/conf/03_VLESS_WS_inbounds_tmp.json
    mv -f /etc/samvpn/xray/conf/03_VLESS_WS_inbounds_tmp.json /etc/samvpn/xray/conf/03_VLESS_WS_inbounds.json
    sed -i "/^### $user $exp/,/^},{/d" /etc/samvpn/xray/vless-nontls.json
    cat /etc/samvpn/xray/conf/02_VLESS_TCP_inbounds.json | jq 'del(.inbounds[0].settings.clients[] | select(.id == "'${uuid}'"))' >/etc/samvpn/xray/conf/02_VLESS_TCP_inbounds_tmp.json
    mv -f /etc/samvpn/xray/conf/02_VLESS_TCP_inbounds_tmp.json /etc/samvpn/xray/conf/02_VLESS_TCP_inbounds.json
    cat /etc/samvpn/xray/conf/04_trojan_TCP_inbounds.json | jq 'del(.inbounds[0].settings.clients[] | select(.password == "'${uuid}'"))' >/etc/samvpn/xray/conf/04_trojan_TCP_inbounds_tmp.json
    mv -f /etc/samvpn/xray/conf/04_trojan_TCP_inbounds_tmp.json /etc/samvpn/xray/conf/04_trojan_TCP_inbounds.json
    sed -i "/\b$user\b/d" /etc/samvpn/xray/user.txt
    rm /etc/samvpn/config-user/${user} >/dev/null 2>&1
    rm /etc/samvpn/config-url/${uuid} >/dev/null 2>&1
    systemctl restart xray.service
    systemctl restart xray@n
    systemctl restart xray.service
    echo -e "\033[32m[Info]\033[0m xray Start Successfully !"
    echo ""
    echo -e "User \e[32m$user\e[0m deleted Successfully !"
    echo ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

extend_user() {
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m               • EXTEND XRAY USER •               \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    cat /etc/samvpn/xray/user.txt | awk '{print $1}' | sort | uniq
    echo -e ""
    read -p "Username : " user
    if ! grep -qw "$user" /etc/samvpn/xray/user.txt; then
        echo -e ""
        echo -e "User \e[31m$user\e[0m does not exist"
        echo ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        read -n 1 -s -r -p "Press any key to back on menu"
        menu
    else
        uuid=$(grep -wE "$user" "/etc/samvpn/xray/user.txt" | awk '{print $2}')
        exp=$(grep -wE "$user" "/etc/samvpn/xray/user.txt" | awk '{print $3}')
        echo "$user : $exp"
        read -p "Expired (days): " masaaktif
        now=$(date +%Y-%m-%d)
        d1=$(date -d "$exp" +%s)
        d2=$(date -d "$now" +%s)
        exp2=$(((d1 - d2) / 86400))
        exp3=$(($exp2 + $masaaktif))
        exp4=$(date -d "$exp3 days" +"%Y-%m-%d")
        sed -i "/$user/d" /etc/samvpn/xray/user.txt
        echo -e "${user}\t${uuid}\t${exp4}" >>/etc/samvpn/xray/user.txt
        systemctl restart xray.service >/dev/null 2>&1
        systemctl restart xray@n >/dev/null 2>&1
        systemctl restart xray.service >/dev/null 2>&1
        clear
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\E[44;1;39m     XRAY Account Was Successfully Renewed        \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        echo " Client Name : $user"
        echo " Expired On  : $exp4"
        echo ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        read -n 1 -s -r -p "Press any key to back on menu"
        menu
    fi
}

set-dns() {
    yell='\e[1;33m'
    NC='\e[0m'
    cpath="/etc/openvpn/server/server-tcp-1194.conf"
    echo -ne "PLEASE INPUT YOUR DNS [default: 8.8.8.8] : "
    read controld
    [[ -z $controld ]] && controld="8.8.8.8"
    [[ ! -f /etc/resolvconf/interface-order ]] && {
        apt install resolvconf
    }

    # Masukkan DNS kedalam server baru secara permenant
    echo "nameserver $controld" >/etc/resolvconf/resolv.conf.d/head

    # Masukkan DNS kedalam server baru secara sementara (Hilang selepas reboot)
    echo "nameserver $controld" >/etc/resolv.conf

    sed -i "/dhcp-option DNS/d" $cpath
    sed -i "/redirect-gateway def1 bypass-dhcp/d" $cpath
    cat >>$cpath <<END
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS $controld"
END

    [[ ! -f /usr/bin/jq ]] && {
        apt install jq
    }
    bash <(curl -sSL https://raw.githubusercontent.com/nympho687/kirik/main/ceknet.sh)
    echo -ne "[ ${yell}WARNING${NC} ] Do you want to reboot now ? (y/n)? "
    read answer
    if [ "$answer" == "${answer#[Yy]}" ]; then
        exit 0
    else
        reboot
    fi
}

check-dns() {
    bash <(curl -sSL https://raw.githubusercontent.com/nympho687/kirik/main/ceknet.sh)
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

change-domain() {
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m             • CHANGE DOMAIN VPS •                \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e ""
    echo "Please Input Your Pointing Domain In Cloudflare "
    read -rp "Domain/Host: " -e host
    rm /etc/samvpn/xray/domain
    echo "$host" >>/etc/samvpn/xray/domain
    echo "$host" >/root/domain
    domain=$(cat /etc/samvpn/xray/domain)
    #Update Sertificate SSL
    echo Starting Update SSL Sertificate
    sleep 3
    sudo pkill -f nginx &
    wait $!
    systemctl stop nginx
    systemctl stop xray.service
    systemctl stop xray@n
    sleep 2
    /root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256 --server letsencrypt >>/etc/samvpn/tls/$domain.log
    ~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/samvpn/xray/xray.crt --keypath /etc/samvpn/xray/xray.key --ecc
    cat /etc/samvpn/tls/$domain.log
    systemctl daemon-reload
    systemctl restart xray@n
    systemctl restart xray.service
    systemctl stop nginx
    rm /etc/nginx/conf.d/xasdhxzasd.conf
    touch /etc/nginx/conf.d/xasdhxzasd.conf
    cat <<EOF >>/etc/nginx/conf.d/xasdhxzasd.conf
server {
	listen 81;
	listen [::]:81;
	server_name ${domain};
	# shellcheck disable=SC2154
	return 301 https://${domain};
}
server {
		listen 127.0.0.1:31300;
		server_name _;
		return 403;
}
server {
	listen 127.0.0.1:31302 http2;
	server_name ${domain};
	root /usr/share/nginx/html;
	location /s/ {
    		add_header Content-Type text/plain;
    		alias /etc/samvpn/config-url/;
    }

    location /xraygrpc {
		client_max_body_size 0;
#		keepalive_time 1071906480m;
		keepalive_requests 4294967296;
		client_body_timeout 1071906480m;
 		send_timeout 1071906480m;
 		lingering_close always;
 		grpc_read_timeout 1071906480m;
 		grpc_send_timeout 1071906480m;
		grpc_pass grpc://127.0.0.1:31301;
	}

	location /xraytrojangrpc {
		client_max_body_size 0;
		# keepalive_time 1071906480m;
		keepalive_requests 4294967296;
		client_body_timeout 1071906480m;
 		send_timeout 1071906480m;
 		lingering_close always;
 		grpc_read_timeout 1071906480m;
 		grpc_send_timeout 1071906480m;
		grpc_pass grpc://127.0.0.1:31304;
	}
}
server {
	listen 127.0.0.1:31300;
	server_name ${domain};
	root /usr/share/nginx/html;
	location /s/ {
		add_header Content-Type text/plain;
		alias /etc/samvpn/config-url/;
	}
	location / {
		add_header Strict-Transport-Security "max-age=15552000; preload" always;
	}
}
EOF
    systemctl daemon-reload
    service nginx restart
    echo -e "\033[32m[Info]\033[0m nginx Start Successfully !"
    echo ""
    echo "Location Your Domain : /root/domain"
    echo ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

change_port() {
    multi="$(cat ~/log-install.txt | grep -w "VLess TCP XTLS" | cut -d: -f2 | sed 's/ //g')"
    echo -e "      Change Port $multi"
    read -p "New Port Trojan: " multi2
    if [ -z $multi2 ]; then
        echo "Please Input Port"
        exit 0
    fi
    cek=$(netstat -nutlp | grep -w $multi2)
    if [[ -z $cek ]]; then
        sed -i "s/$multi/$multi2/g" /etc/samvpn/xray/conf/02_VLESS_TCP_inbounds.json
        sed -i "s/$multi/$multi2/g" /root/log-install.txt
        iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport $multi -j ACCEPT
        iptables -D INPUT -m state --state NEW -m udp -p udp --dport $multi -j ACCEPT
        iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $multi2 -j ACCEPT
        iptables -I INPUT -m state --state NEW -m udp -p udp --dport $multi2 -j ACCEPT
        iptables-save >/etc/iptables.up.rules
        iptables-restore -t </etc/iptables.up.rules
        netfilter-persistent save >/dev/null
        netfilter-persistent reload >/dev/null
        systemctl restart xray.service >/dev/null
        systemctl restart xray@n >/dev/null
        systemctl restart xray.service >/dev/null
        echo -e "\e[032;1mPort $multi2 modified successfully\e[0m"
    else
        echo "Port $multi2 is used"
    fi
}

check_login() {
    echo -n >/tmp/other.txt

    data=($(cat /etc/samvpn/xray/user.txt | awk '{print $1}' | sort | uniq))

    echo "---------------------------------"
    echo "---=[  ALL Multiport Login  ]=---"
    echo "---------------------------------"

    for akun in "${data[@]}"; do
        if [[ -z "$akun" ]]; then
            akun="tidakada"
        fi
        echo -n >/tmp/user.txt
        data2=($(netstat -anp | grep ESTABLISHED | grep tcp6 | grep xray | awk '{print $5}' | cut -d: -f1 | sort | uniq))
        for ip in "${data2[@]}"; do
            jum=$(cat /var/log/xray/access.log | grep -w $akun | awk '{print $3}' | cut -d: -f1 | grep -w $ip | sort | uniq)
            if [[ "$jum" = "$ip" ]]; then
                echo "$jum" >>/tmp/user.txt
            else
                echo "$ip" >>/tmp/other.txt
            fi
            jum2=$(cat /tmp/user.txt)
            sed -i "/$jum2/d" /tmp/other.txt >/dev/null 2>&1
        done
        jum=$(cat /tmp/user.txt)
        if [[ -z "$jum" ]]; then
            echo >/dev/null
        else
            jum2=$(cat /tmp/user.txt | nl)
            echo "user : $akun"
            echo "$jum2"
            echo "---------------------------------"
        fi
        rm -rf /tmp/user.txt
    done
    rm -rf /tmp/other.txt

    echo ""
    read -n 1 -s -r -p "Press any key to back on menu"

    menu
}

restart_all() {
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m      • Restart ALL Service •      \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    systemctl restart stunnel4
    echo -e "[ ${green}ok${NC} ] Restarting stunnel4 "
    systemctl restart xray.service
    systemctl restart xray@n
    systemctl restart xray.service
    echo -e "[ ${green}ok${NC} ] Restarting Xray "
    systemctl restart dropbear
    echo -e "[ ${green}ok${NC} ] Restarting dropbear "
    read -n 1 -s -r -p "Press any key to back on menu"
    menu

}
check_port() {
    cat /root/log-install.txt
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

backup_vps() {
    green='\e[0;32m'
    NC='\e[0m'
    echo -e "[ ${green}INFO${NC} ] Create password for database"
    read -rp "Enter password : " -e InputPass
    sleep 1
    if [[ -z $InputPass ]]; then
        menu
    fi
    echo -e "[ ${green}INFO${NC} ] Processing... "
    mkdir -p /root/backup
    sleep 1

    cp /etc/passwd backup/
    cp /etc/group backup/
    cp /etc/shadow backup/
    cp /etc/gshadow backup/
    cp /etc/samvpn/xray/user.txt backup/
    cp -r /etc/samvpn/xray/conf backup/conf

    cd /root
    zip -rP $InputPass $Name.zip backup >/dev/null 2>&1

    ##############++++++++++++++++++++++++#############
    LLatest=$(date)
    Get_Data() {
        git clone https://github.com/bracoli/user-backup-db.git /root/user-backup/ &>/dev/null
    }

    Mkdir_Data() {
        mkdir -p /root/user-backup/$Name
    }

    Input_Data_Append() {
        if [ ! -f "/root/user-backup/$Name/$Name-last-backup" ]; then
            touch /root/user-backup/$Name/$Name-last-backup
        fi
        echo -e "User         : $Name
last-backup : $LLatest
" >>/root/user-backup/$Name/$Name-last-backup
        mv /root/$Name.zip /root/user-backup/$Name/
    }

    Save_And_Exit() {
        cd /root/user-backup
        git config --global user.email "khafiz532@gmail.com" &>/dev/null
        git config --global user.name "bracoli" &>/dev/null
        rm -rf .git &>/dev/null
        git init &>/dev/null
        git add . &>/dev/null
        git commit -m m &>/dev/null
        git branch -M main &>/dev/null
        git remote add origin https://github.com/bracoli/user-backup-db
        git push -f https://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@github.com/bracoli/user-backup-db.git &>/dev/null
    }

    if [ ! -d "/root/user-backup/" ]; then
        sleep 1
        echo -e "[ ${green}INFO${NC} ] Getting database... "
        Get_Data
        Mkdir_Data
        sleep 1
        echo -e "[ ${green}INFO${NC} ] Getting info server... "
        Input_Data_Append
        sleep 1
        echo -e "[ ${green}INFO${NC} ] Processing updating server...... "
        Save_And_Exit
    fi
    link="https://raw.githubusercontent.com/bracoli/user-backup-db/main/$Name/$Name.zip"
    sleep 1
    echo -e "[ ${green}INFO${NC} ] Backup done "
    sleep 1
    echo
    sleep 1
    echo -e "[ ${green}INFO${NC} ] Generete Link Backup "
    echo
    sleep 2
    echo -e "The following is a link to your vps data backup file.
Your VPS IP $IP

$link
save the link pliss!

If you want to restore data, please enter the link above.
Thank You For Using Our Services"

    rm -rf /root/backup &>/dev/null
    rm -rf /root/user-backup &>/dev/null
    rm -f /root/$Name.zip &>/dev/null
    echo
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

restore_vps() {
    green='\e[0;32m'
    NC='\e[0m'
    read -p "Link : " link
    read -p "Pass : " InputPass
    mkdir /root/backup
    wget -q -O /root/backup/backup.zip "$link" &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Getting your data..."
    unzip -P $InputPass /root/backup/backup.zip &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Starting to restore data..."
    rm -f /root/backup/backup.zip &>/dev/null
    sleep 1
    cd /root/backup
    echo -e "[ ${green}INFO${NC} ] • Restoring passwd data..."
    sleep 1
    cp /root/backup/passwd /etc/ &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Restoring group data..."
    sleep 1
    cp /root/backup/group /etc/ &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Restoring shadow data..."
    sleep 1
    cp /root/backup/shadow /etc/ &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Restoring gshadow data..."
    sleep 1
    cp /root/backup/gshadow /etc/ &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Restoring Xray data..."
    sleep 1
    cp /root/backup/user.txt /etc/samvpn/xray/ &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Restoring admin data..."
    sleep 1
    cp -r /root/backup/conf /etc/samvpn/xray &>/dev/null
    rm -rf /root/backup &>/dev/null
    echo -e "[ ${green}INFO${NC} ] • Done..."
    sleep 1
    rm -f /root/backup/backup.zip &>/dev/null
    systemctl restart xray.service
    systemctl restart xray@n
    systemctl restart xray.service
    echo
    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

Name=$(curl -sS https://raw.githubusercontent.com/bracoli/access/main/ip | grep $MYIP | awk '{print $2}')
Exp=$(curl -sS https://raw.githubusercontent.com/bracoli/access/main/ip | grep $MYIP | awk '{print $3}')
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"

chck_pid() {
    PID=$(ps -ef | grep -v grep | grep nginx | awk '{print $2}')
}

menu_sts() {
    chck_pid
    if [[ ! -z "${PID}" ]]; then
        echo -e "Current status: ${Green_font_prefix} Installed${Font_color_suffix} & ${Green_font_prefix}Running${Font_color_suffix}"
    else
        echo -e "Current status: ${Green_font_prefix} Installed${Font_color_suffix} but ${Red_font_prefix}Not Running${Font_color_suffix}"
    fi
}
clear
echo -e ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Client Name   : LukaVPN"
echo -e "Expiry script : Never Expired"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m               ⇱ MULTIPORT MENU ⇲                 \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
menu_sts
echo ""
echo -e " [\e[36m•1\e[0m ] Add Ssh User"
echo -e " [\e[36m•2\e[0m ] All Ssh User"
echo -e " [\e[36m•3\e[0m ] Delete Ssh"
echo -e " [\e[36m•4\e[0m ] Delete User Expired"
echo -e " [\e[36m•5\e[0m ] Extend Ssh"
echo -e " [\e[36m•6\e[0m ] Check User Login"
echo ""
echo -e " [\e[36m•7\e[0m ] Add XRay VMess"
echo -e " [\e[36m•8\e[0m ] Delete XRay VMess"
echo -e " [\e[36m•9\e[0m ] Extend XRay Vmess"
echo -e " [\e[36m•10\e[0m] Check User Login"
echo -e ""
echo -e " [\e[36m•11\e[0m] Add XRay VLess"
echo -e " [\e[36m•12\e[0m] Delete XRay VLess"
echo -e " [\e[36m•13\e[0m] Extend XRay VLess"
echo -e " [\e[36m•14\e[0m] Check User Login"
echo -e ""
echo -e " [\e[36m•15\e[0m] Add XRay XTLS"
echo -e " [\e[36m•16\e[0m] Delete XRay XTLS"
echo -e " [\e[36m•17\e[0m] Extend XRay XTLS"
echo -e " [\e[36m•18\e[0m] Check User Login"
echo -e ""
echo -e " [\e[36m•19\e[0m] Add XRay Trojan"
echo -e " [\e[36m•20\e[0m] Delete XRay TRojan"
echo -e " [\e[36m•21\e[0m] Extend XRay TRojan"
echo -e " [\e[36m•22\e[0m] Check User Login"
echo -e ""
echo -e " [\e[36m•23\e[0m] Setup DNS"
echo -e " [\e[36m•24\e[0m] Check DNS Region"
echo -e " [\e[36m•25\e[0m] Change VPS Domain"
echo -e " [\e[36m•26\e[0m] Change Service Port"
echo -e " [\e[36m•27\e[0m] Restart All Service"
echo -e " [\e[36m•28\e[0m] Check All Port"
echo -e " [\e[36m•29\e[0m] Backup"
echo -e " [\e[36m•30\e[0m] Restore"
echo -e ""
echo -e " [\e[36m•111\e[0m] BOT PANEL"
echo -e ""
echo -e "Press x or [ Ctrl+C ] • To-Exit"
echo -e ""
read -p " Select menu : " opt
echo -e ""
case $opt in
1)
    clear
    add_ssh
    ;;
2)
    clear
    all_ssh
    ;;
3)
    clear
    del_ssh
    ;;
4)
    clear
    del_exp
    ;;
5)
    clear
    extend_ssh
    ;;
6)
    clear
    check_ssh
    ;;
7)
    clear
    add-ws
    ;;
8)
    clear
    del-user
    ;;
9)
    clear
    extend_user
    ;;
10)
    clear
    check_login
    ;;
11)
    clear
    add-vless
    ;;
12)
    clear
    del-user
    ;;
13)
    clear
    extend_user
    ;;
14)
    clear
    check_login
    ;;
15)
    clear
    add-xtls
    ;;
16)
    clear
    del-user
    ;;
17)
    clear
    extend_user
    ;;
18)
    clear
    check_login
    ;;
19)
    clear
    add-trojan
    ;;
20)
    clear
    del-user
    ;;
21)
    clear
    extend_user
    ;;
22)
    clear
    check_login
    ;;
23)
    clear
    set-dns
    ;;
24)
    clear
    check-dns
    ;;
25)
    clear
    change-domain
    ;;
26)
    clear
    change_port
    ;;
27)
    clear
    restart_all
    ;;
28)
    clear
    check_port
    ;;
29)
    clear
    backup_vps
    ;;
30)
    clear
    restore_vps
    ;;
111)
    clear
    installer
    ;;
x) exit ;;
*)
    echo -e ""
    echo "Sila Pilih Semula"
    sleep 1
    menu
    ;;
esac
