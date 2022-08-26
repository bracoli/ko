#!/bin/bash 

#----- Auto Remove User
data=($(awk '{print $1}' /etc/samvpn/xray/user.txt))
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"; do
  exp=$(grep -w "$user" /etc/samvpn/xray/user.txt | awk '{print $3}')
  uuid="$(cat /etc/samvpn/xray/user.txt | grep -w "$user" | awk '{print $2}')"
  d1=$(date -d "$exp" +%s)
  d2=$(date -d "$now" +%s)
  exp2=$(((d1 - d2) / 86400))
  if [[ "$exp2" -le "0" ]]; then
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
  fi
done