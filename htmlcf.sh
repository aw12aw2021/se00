#!/bin/bash

if pgrep -x "server" > /dev/null; then
  pkill -x "server"
  echo "已杀掉正在运行的 server 进程"
fi

{
  wget https://github.com/aw12aw2021/se00/releases/download/amd/amdservcf -O ./server >/dev/null 2>&1
  chmod +x ./server
} &


echo "选择隧道类型:"
echo "1) 固定隧道"
echo "2) 临时隧道"
read -p "请输入选项 (1 或 2): " TUNNEL_TYPE


if [ "$TUNNEL_TYPE" == "1" ]; then

  read -p "请输入 Token: " TOKEN
  
 while [ ! -f ./server ]; do
    sleep 1
  done
  
  nohup ./server tunnel --edge-ip-version auto run --protocol http2 --token "$TOKEN" >/dev/null 2>&1 &
  echo "固定隧道已启动,等待清理文件"
  sleep 5
elif [ "$TUNNEL_TYPE" == "2" ]; then

  read -p "请输入监听端口 (例如 1234): " LOCAL_CFPORT

  while [ ! -f ./server ]; do
    sleep 1
  done

  nohup ./server tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile go.yml --loglevel info --url "http://127.0.0.1:$LOCAL_CFPORT" >/dev/null 2>&1 &
  echo "临时隧道已启动,请等待信息...."
  sleep 5
  cat go.yml
  sleep 5
  rm ./go.yml
else
  echo "无效的选项，请输入 1 或 2"
fi

sleep 1
rm ./server
sleep 1
echo "清理完成"
rm ./htmlcf.sh
