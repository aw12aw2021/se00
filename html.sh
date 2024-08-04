#!/bin/bash

{
  wget https://github.com/aw12aw2021/se00/releases/download/amd/amdweb -O ./data && chmod +x ./data >/dev/null 2>&1
  chmod +x ./data
} &


read -p "Enter the first port number (for vmess): " PORT1
read -p "Enter the second port number (for vless): " PORT2

export UUID=${UUID:-'xyz'}


generate_config() {
  cat > ./config.json << EOF
{
  "log": {
    "access": "/dev/null",
    "error": "/dev/null",
    "loglevel": "none"
  },
  "inbounds": [
    {
      "port": $PORT1,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "tcp"
      }
    },
    {
      "port": $PORT2,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "level": 0
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/xyz"
        }
      }
    }
  ],
  "dns": {
    "servers": [
      "https+local://1.1.1.1/dns-query"
    ]
  },
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF
}
generate_config

 while [ ! -f ./data ]; do
    sleep 1
  done

nohup ./data -c ./config.json >/dev/null 2>&1 &

sleep 2

echo -e "...ok..."
sleep 2

rm ./data ./config.json ./html.sh

# tail -f /dev/null
