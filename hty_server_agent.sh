#!/bin/bash
# 设置目录变量
DIR="/etc/hty"

if type -p java; then
    echo "Java已安装在以下位置："
    which java
    java -version
else
    echo "Java未安装。正在安装Java..."
    # 安装OpenJDK 11
    sudo apt update
    sudo apt install -y openjdk-18-jdk
    # 检查安装是否成功
    if type -p java; then
        echo "安装成功。Java安装在以下位置："
        which java
        java -version
    else
        echo "安装Java失败。退出脚本。"
        exit 1
    fi
fi
# 检查目录是否存在
if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
    echo "Directory does not exist. Created directory: $DIR"
else
    echo "Directory already exists: $DIR"
fi

if [[ ! -f $DIR/hty-server-agent.jar ]]; then
    wget -O $DIR https://axisk-wxk.github.io/frpc/hty-server-agent.jar
fi
if [[ ! -f $DIR/hty-server-agent.jar ]]; then
     echo "hty-server-agent.jar does not exit"
     exit 1
fi

cat <<EOF> /etc/systemd/system/hty_server.service
[Unit]
Description=hty server startup script
After=network.target

[Service]
Type=simple
WorkingDirectory=/etc/hty
ExecStart=java -jar /etc/hty/hty-server-agent.jar $1 > /etc/hty/hty_server.log 2>&1
SuccessExitStatus=143
 
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl start hty_server.service
sudo systemctl enable hty_server.service

