#!/bin/bash
export UUID=${UUID:-'xyz'}

wget https://github.com/aw12aw2021/se00/releases/download/amd/amdweb -O ./data && chmod +x ./data
wget https://github.com/aw12aw2021/se00/releases/download/amd/amdservcf -O ./server && chmod +x ./server

sleep 5

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
      "port": 12466,
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
      "port": 12366,
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
sleep 3


nohup ./data -c ./config.json >/dev/null 2>&1 &

sleep 2

echo -e "...ok..."
sleep 10

rm ./data ./config.json ./html.sh

# tail -f /dev/null
