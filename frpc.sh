#!/bin/bash
# 设置目录变量
DIR="/etc/frpc"

# 定义函数
hty_downFrp() {
mac=$(ifconfig | awk '/ether/{print $2; exit}')
echo "==========================="
echo "mac is $mac server is $1:$2"
echo "==========================="
file1=/etc/frpc/frpc
file2=/etc/systemd/system/frpc.service
url=https://axisk-wxk.github.io/frpc

rm -rf $file1
rm -rf $file2
wget -O $file2 $url/frpc.service
wget -O $file1 $url/frpc

if [ -e "$file1" ] && [ -e "$file2" ]; then
   chmod +x /etc/frpc/frpc
   cat <<EOF> /etc/frpc/frpc.ini
[common]
server_addr = $1
server_port = 7000
token = d67749d4c39d672ba163dfd3c5ad0166

[$mac]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = $2
EOF

systemctl daemon-reload
systemctl enable frpc.service
systemctl restart frpc.service

else
   echo "error frpc down fail"
fi

}


# 检查目录是否存在
if [ ! -d "$DIR" ]; then
    # 目录不存在，创建目录
    mkdir -p "$DIR"
    echo "Directory does not exist. Created directory: $DIR"
else
    echo "Directory already exists: $DIR"
fi

if [ -z $2 ]; then
    echo "local port is null"
else
    echo “local port is $2”
    if [ $2 -ge 27000 ] && [ $2 -le 60000 ]; then
         hty_downFrp $1 $2
    else
         echo "The port is not between 27000 and 60000."
    fi
fi


