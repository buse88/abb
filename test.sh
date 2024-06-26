#!/bin/bash

# ANSI颜色码定义
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 提示用户选择操作
echo -e "${GREEN}请选择操作：${NC}"
echo -e "${GREEN}1. 安装 V2RayA 和 V2Ray${NC}"
echo -e "${GREEN}2. 卸载 V2RayA 和 V2Ray${NC}"
echo -e "${GREEN}3. 更改 V2RayA 密码${NC}"
read -p "输入选择的编号 (1/2/3): " choice

if [ "$choice" == "1" ]; then
    # 安装 V2RayA 和 V2Ray
    echo "正在安装 V2RayA 和 V2Ray..."
    wget -qO - https://apt.v2raya.org/key/public-key.asc | sudo tee /etc/apt/keyrings/v2raya.asc
    echo "deb [signed-by=/etc/apt/keyrings/v2raya.asc] https://apt.v2raya.org/ v2raya main" | sudo tee /etc/apt/sources.list.d/v2raya.list
    sudo apt update
    sudo apt install -y v2raya v2ray
    sudo systemctl start v2raya.service
    echo "安装完成。"

    # 提示用户完成代理设置
    read -p "是否已完成代理设置？(输入 'y' 完成): " proxy_setup
    if [ "$proxy_setup" == "y" ]; then
        # 提示用户选择要安装的版本
        echo -e "${GREEN}请选择要安装的版本：${NC}"
        echo -e "${GREEN}1. 5.4${NC}"
        echo -e "${GREEN}2. 6.1${NC}"
        read -p "输入选择的版本编号 (1/2): " kernel_choice

        # 根据用户选择替换 KERNEL=
        if [ "$kernel_choice" == "1" ]; then
            kernel_version="5.4"
        elif [ "$kernel_choice" == "2" ]; then
            kernel_version="6.1"
        else
            echo "无效的选择。请重新运行脚本并选择 1 或 2。"
            exit 1
        fi

        # 执行代理设置命令，并替换 KERNEL=
        wget -O - https://www.openmptcprouter.com/server/debian-x86_64.sh |  KERNEL="$kernel_version" sh
    fi

elif [ "$choice" == "2" ]; then
    # 卸载 V2RayA 和 V2Ray
    echo "正在卸载 V2RayA 和 V2Ray..."
    sudo systemctl stop v2raya.service
    sudo apt remove --purge -y v2raya v2ray
    sudo rm /etc/apt/sources.list.d/v2raya.list
    sudo rm /etc/apt/keyrings/v2raya.asc
    sudo rm -rf /etc/v2raya
    sudo rm -rf /etc/v2ray
    sudo rm -rf /usr/local/etc/v2ray
    sudo rm -rf ~/.config/v2raya
    sudo rm -rf ~/.config/v2ray
    sudo apt update
    echo "卸载完成。"

    # 删除自身
    echo "删除脚本自身..."
    rm -- "$0"

elif [ "$choice" == "3" ]; then
    # 更改 V2RayA 密码
    read -p "请输入新密码: " new_password
    sudo v2raya config set --key web.password --value "$new_password"
    echo "密码更改完成。"

else
    echo "无效的选择。请运行脚本并选择 1, 2 或 3。"
fi
