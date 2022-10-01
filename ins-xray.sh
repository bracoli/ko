#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")
sudo apt install gnupg2 ca-certificates lsb-release -y
echo "deb http://nginx.org/packages/mainline/debian $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx
curl -o /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key
# gpg --dry-run --quiet --import --import-options import-show /tmp/nginx_signing.key
sudo mv /tmp/nginx_signing.key /etc/apt/trusted.gpg.d/nginx_signing.asc
sudo apt update
apt -y install nginx
systemctl daemon-reload
systemctl enable nginx
domain=$(cat /root/domain)
rm -f /etc/nginx/conf.d/xasdhxzasd.conf
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

    location /directions {
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

	location /directions2 {
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

sed -i "s/80/81/g" /etc/nginx/sites-enabled/default

mkdir /etc/systemd/system/nginx.service.d
printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" >/etc/systemd/system/nginx.service.d/override.conf
rm /etc/nginx/conf.d/default.conf
systemctl daemon-reload
service nginx restart

mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
sudo pkill -f nginx &
wait $!
systemctl stop nginx
sleep 2
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256 --server letsencrypt >>/etc/samvpn/tls/$domain.log
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/samvpn/xray/xray.crt --keypath /etc/samvpn/xray/xray.key --ecc
# Uuid Service
uuid=$(cat /proc/sys/kernel/random/uuid)
# INSTALL XRAY
wget -c -P /etc/samvpn/xray/ "https://github.com/XTLS/Xray-core/releases/download/v1.4.5/Xray-linux-64.zip"
unzip -o /etc/samvpn/xray/Xray-linux-64.zip -d /etc/samvpn/xray
rm -rf /etc/samvpn/xray/Xray-linux-64.zip
chmod 655 /etc/samvpn/xray/xray
# XRay boot service
cat <<EOF >/etc/systemd/system/xray.service
[Unit]
Description=Xray - A unified platform for anti-censorship
# Documentation=https://xraynt.com https://guide.v2fly.org
After=network.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=yes
ExecStart=/etc/samvpn/xray/xray run -confdir /etc/samvpn/xray/conf
Restart=on-failure
RestartPreventExitStatus=23


[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/systemd/system/xray@n.service
[Unit]
Description=Xray - A unified platform for anti-censorship
# Documentation=https://xraynt.com https://guide.v2fly.org
After=network.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=yes
ExecStart=/etc/samvpn/xray/xray run -config /etc/samvpn/xray/vless-nontls.json
Restart=on-failure
RestartPreventExitStatus=23


[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable xray.service
rm -rf /etc/samvpn/xray/conf/*
cat <<EOF >/etc/samvpn/xray/conf/00_log.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  }
}
EOF
cat <<EOF >/etc/samvpn/xray/conf/10_ipv4_outbounds.json
{
    "outbounds":[
        {
            "protocol":"freedom",
            "settings":{
                "domainStrategy":"UseIPv4"
            },
            "tag":"IPv4-out"
        },
        {
            "protocol":"freedom",
            "settings":{
                "domainStrategy":"UseIPv6"
            },
            "tag":"IPv6-out"
        },
        {
            "protocol":"blackhole",
            "tag":"blackhole-out"
        }
    ]
}
EOF
cat <<EOF >/etc/samvpn/xray/conf/11_dns.json
{
    "dns": {
        "servers": [
          "localhost"
        ]
  }
}
EOF
cat <<EOF >/etc/samvpn/xray/conf/02_VLESS_TCP_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "tag": "VLESSTCP",
      "settings": {
        "clients": [],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 31296,
            "xver": 1
          },
          {
            "alpn": "h1",
            "dest": 31333,
            "xver": 0
          },
          {
            "alpn": "h2",
            "dest": 31302,
            "xver": 0
          },
          {
            "path": "/xrayws",
            "dest": 31297,
            "xver": 1
          },
          {
            "path": "/xrayvws",
            "dest": 31299,
            "xver": 1
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "xtls",
        "xtlsSettings": {
          "minVersion": "1.2",
          "alpn": [
            "http/1.1",
            "h2"
          ],
          "certificates": [
            {
              "certificateFile": "/etc/samvpn/xray/xray.crt",
              "keyFile": "/etc/samvpn/xray/xray.key",
              "ocspStapling": 3600,
              "usage": "encipherment"
            }
          ]
        }
      }
    }
  ]
}
EOF
cat <<EOF >/etc/samvpn/xray/conf/03_VLESS_WS_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 31297,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "tag": "VLESSWS",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/xrayws"
        }
      }
    }
  ]
}
EOF
cat <<EOF >/etc/samvpn/xray/conf/04_trojan_gRPC_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
    "inbounds": [
        {
            "port": 31304,
            "listen": "127.0.0.1",
            "protocol": "trojan",
            "tag": "trojangRPCTCP",
            "settings": {
                "clients": [
                    {
                        "password": "9dcc73ba-c90a-4de9-be35-be3da0129768",
                        "email": "${domain}_trojan_gRPC"
                    }
                ],
                "fallbacks": [
                    {
                        "dest": "31300"
                    }
                ]
            },
            "streamSettings": {
                "network": "grpc",
                "grpcSettings": {
                    "serviceName": "directions2"
                }
            }
        }
    ]
}
EOF
cat <<EOF >/etc/samvpn/xray/conf/04_trojan_TCP_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 31296,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "tag": "trojanTCP",
      "settings": {
        "clients": [],
        "fallbacks": [
          {
            "dest": "31300"
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none",
        "tcpSettings": {
          "acceptProxyProtocol": true
        }
      }
    }
  ]
}
EOF
cat <<EOF >/etc/samvpn/xray/conf/10_trojan_XTLS_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 31230,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "tag": "trojanXTLS",
      "settings": {
        "clients": [],
        "fallbacks": [
          {
            "dest": "31333"
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "xtls",
        "xtlsSettings": {
             "alpn": [
            "http/1.1",
            "h1"
          ]
        }
      }
    }
  ]
}
EOF
cat <<EOF >/etc/samvpn/xray/conf/05_VMess_WS_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 31299,
      "protocol": "vmess",
      "tag": "VMessWS",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/xrayvws"
        }
      }
    }
  ]
}
EOF
cat <<EOF >/etc/samvpn/xray/conf/06_VLESS_gRPC_inbounds.json
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
    "inbounds":[
    {
        "port": 31301,
        "listen": "127.0.0.1",
        "protocol": "vless",
        "tag":"VLESSGRPC",
        "settings": {
            "clients": [],
            "decryption": "none"
        },
        "streamSettings": {
            "network": "grpc",
            "grpcSettings": {
                "serviceName": "directions"
            }
        }
    }
]
}
EOF

cat >/etc/samvpn/xray/conf/vmess-nontls.json <<END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 80,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 0
#xray
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/xrayws",
          "headers": {
            "Host": ""
          }
         },
        "quicSettings": {},
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      },
      "domain": "$domain"
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  }
}
END

cat >/etc/samvpn/xray/vless-nontls.json <<END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error2.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 8000,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}"
#xray
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/xrayws",
          "headers": {
            "Host": ""
          }
         },
        "quicSettings": {},
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      },
      "domain": "$domain"
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  }
}
END

# xray
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 31301 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 31299 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 31296 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 31304 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 31297 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 31230 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8000 -j ACCEPT
# xray
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 31301 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 31299 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 31296 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 31304 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 31297 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 31230 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8000 -j ACCEPT
iptables-save >/etc/iptables.rules.v4
netfilter-persistent save
netfilter-persistent reload
systemctl daemon-reload

# Starting
systemctl daemon-reload
systemctl restart xray
systemctl enable xray
systemctl restart xray.service
systemctl enable xray.service
