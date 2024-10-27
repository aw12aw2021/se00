#!/bin/bash

DATA_URL="https://github.com/aw12aw2021/se00/releases/download/lade/web.js"
DATA_FILE="./data"
CONFIG_FILE="./config.json"
UUID_DEFAULT='xyz'
PORT_PATH="/xyz"


command -v wget >/dev/null 2>&1 || { echo >&2 "需要 wget，但未安装。请安装后重试。"; exit 1; }


if pgrep -x "data" > /dev/null; then
  pkill -x "data"
  echo "已杀掉正在运行的所有 data 进程"
fi


{
  wget "$DATA_URL" -O "$DATA_FILE" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "文件下载失败，请检查网络或 URL 是否正确。"
    exit 1
  fi
  chmod +x "$DATA_FILE"
} &


echo "输入 '1' >>>>节点 vless-ws"
echo "输入 '2' >>>>节点 vmess-ws + vless-ws"
read -p "请输入选项: " USE_ONE_PORT

read -p "输入 UUID (直接回车 = '$UUID_DEFAULT'): " UUID
UUID=${UUID:-$UUID_DEFAULT}


USE_ONE_PORT=${USE_ONE_PORT:-'1'}

if [ "$USE_ONE_PORT" == "2" ]; then
  read -p "输入端口1 (vmess-ws): " PORT1
  read -p "输入端口2 (vless-ws): " PORT2
else
  read -p "输入端口 (vless-ws): " PORT2
fi


generate_config() {
  if [ "$USE_ONE_PORT" == "2" ]; then
    cat > "$CONFIG_FILE" << EOF
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
        "network": "ws",
        "wsSettings": {
          "path": "$PORT_PATH"
        }
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
          "path": "$PORT_PATH"
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
    cat > "$CONFIG_FILE" << EOF
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
          "path": "$PORT_PATH"
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


timeout=30
start_time=$(date +%s)
while [ ! -f "$DATA_FILE" ] || [ ! -x "$DATA_FILE" ]; do
  sleep 1
  current_time=$(date +%s)
  if [ $((current_time - start_time)) -ge $timeout ]; then
    echo "等待 data 文件准备超时，脚本退出。"
    exit 1
  fi
done


if [ ! -f "$CONFIG_FILE" ]; then
  echo "配置文件生成失败，脚本退出。"
  exit 1
fi

echo -e "文件准备完成,正在运行....."


nohup "$DATA_FILE" -c "$CONFIG_FILE" >/dev/null 2>&1 &
DATA_PID=$!



if ps -p $DATA_PID > /dev/null; then
  echo "服务已经运行"
else
  echo "服务启动失败"
fi


rm "$DATA_FILE" "$CONFIG_FILE"

sleep 2
echo "清理完成"
rm ./html.sh


# tail -f /dev/null
