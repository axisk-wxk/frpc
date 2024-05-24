#!/bin/bash
# 设置目录变量
DIR="/etc/hty"
java -version > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Java is installed and supported."
else
    echo "Java is not installed or not supported."
    sudo apt update
    sudo apt install -y openjdk-18-jdk
java -version > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Java 安装成功."
else
    echo "Java 安装失败."
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

if [ ! -f $DIR/hty-server-agent.jar ]; then
    echo "downing agent.jar"
    wget -O $DIR/hty-server-agent.jar https://axisk-wxk.github.io/frpc/hty-server-agent.jar
fi
if [ ! -f $DIR/hty-server-agent.jar ]; then
     echo "hty-server-agent.jar does not exit"
     exit 1
fi

cat <<EOF> /etc/systemd/system/htyAgent.service
[Unit]
Description=hty server agent startup script
After=network.target

[Service]
Type=simple
WorkingDirectory=/etc/hty
ExecStart=java -jar /etc/hty/hty-server-agent.jar $1 > /etc/hty/agent.log 2>&1
SuccessExitStatus=143
 
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl restart htyAgent.service
sudo systemctl enable htyAgent.service

