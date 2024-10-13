#!/bin/ash
set +e

# define
mkdir -p /screen
SCREEN_DIR="/screen"
INITD_DIR="/etc/init.d"
SCREEN_FILE="startall.sh"
INITD_FILE="lcdserver"
SCREEN_URL="https://raw.githubusercontent.com/buse88/abb/refs/heads/main/screen/startall.sh"
INITD_URL="https://raw.githubusercontent.com/buse88/abb/refs/heads/main/screen/lcdserver"

# /screen/startall.sh 存在就删了
if [ -f "$SCREEN_DIR/$SCREEN_FILE" ]; then
    # 停止并删除
    /etc/init.d/lcdserver stop
    rm "$SCREEN_DIR/$SCREEN_FILE"
fi
set -e
# 下载startall.sh文件
wget -q -O "$SCREEN_DIR/$SCREEN_FILE" "$SCREEN_URL"

# set permissions
chmod a+x "$SCREEN_DIR/$SCREEN_FILE"

# /etc/init.d/lcdserver 存在就删了
if [ -f "$INITD_DIR/$INITD_FILE" ]; then
    # 删除
    rm "$INITD_DIR/$INITD_FILE"
fi

# 重新下载lcdserver到 /etc/init.d
wget -q -O "$INITD_DIR/$INITD_FILE" "$INITD_URL"
# 授权
chmod a+x "$INITD_DIR/$INITD_FILE"

# set startup
/etc/init.d/lcdserver enable
/etc/init.d/lcdserver start
echo "安装成功"
