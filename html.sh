#!/bin/bash

if pgrep -x "data" > /dev/null; then
  pkill -x "datar"
  echo "已杀掉正在运行的 data 进程"
fi

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

# 等待 config.json 生成
while [ ! -f ./config.json ]; do
  sleep 1
done

# 等待 data 文件下载并赋予执行权限
while [ ! -f ./data ] || [ ! -x ./data ]; do
  sleep 1
done

echo -e "文件准备完成,正在运行....."

# 运行 data 并确认进程
nohup ./data -c ./config.json >/dev/null 2>&1 &
DATA_PID=$!

sleep 2  # 等待进程启动

if ps -p $DATA_PID > /dev/null; then
  echo "服务已经运行"
else
  echo "服务启动失败"
fi

rm ./data ./config.json
sleep 2
echo "清理完成"
rm ./html.sh


# tail -f /dev/null
