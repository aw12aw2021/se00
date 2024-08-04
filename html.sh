#!/bin/bash

{
  wget https://github.com/aw12aw2021/se00/releases/download/amd/amdweb -O ./data && chmod +x ./data >/dev/null 2>&1
  chmod +x ./data
} &


read -p "输入 UUID (直接回车 = 'xyz'): " UUID
UUID=${UUID:-'xyz'}


read -p "回车只使用1个端口 (默认 '1'，键入 '2' 开启双节点): " USE_ONE_PORT
USE_ONE_PORT=${USE_ONE_PORT:-'1'}

if [ "$USE_ONE_PORT" == "2" ]; then
  read -p "输入端口1 (vmess-tcp): " PORT1
  read -p "输入端口2 (vless-ws): " PORT2
else
  read -p "输入端口 (vless-ws): " PORT2
fi

generate_config() {
  if [ "$USE_ONE_PORT" == "2" ]; then
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
  else
    cat > ./config.json << EOF
{
  "log": {
    "access": "/dev/null",
    "error": "/dev/null",
    "loglevel": "none"
  },
  "inbounds": [
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
  fi
}

generate_config


while [ ! -f ./data ] || [ ! -x ./data ]; do
  sleep 1
done


nohup ./data -c ./config.json >/dev/null 2>&1 &


sleep 2

echo -e "...ok..."
sleep 2

rm ./data ./config.json ./html.sh

# tail -f /dev/null
