#!/bin/bash

# 定义绿色文字的 ANSI 转义序列
GREEN='\033[0;32m'
NC='\033[0m' # 没有颜色

# 提示用户选择操作
echo "请选择操作："
echo -e "${GREEN}1. 安装 V2 和 V2内核${NC}"
echo -e "${GREEN}2. 卸载 V2 和 V2内核${NC}"
echo -e "${GREEN}3. 清空 V2用户名密码${NC}"
read -p "输入选择的编号 (1/2/3): " choice

if [ "$choice" == "1" ]; then
    # 安装 V2RayA 和 V2Ray
    echo -e "${GREEN}正在安装 V2RayA 和 V2Ray...${NC}"
    wget -qO - https://apt.v2raya.org/key/public-key.asc | sudo tee /etc/apt/keyrings/v2raya.asc
    echo "deb [signed-by=/etc/apt/keyrings/v2raya.asc] https://apt.v2raya.org/ v2raya main" | sudo tee /etc/apt/sources.list.d/v2raya.list
    sudo apt update
    sudo apt install -y v2raya v2ray
    sudo systemctl start v2raya.service
    echo -e "${GREEN}安装完成。${NC}"

elif [ "$choice" == "2" ]; then
    # 卸载 V2RayA 和 V2Ray
    echo -e "${GREEN}正在卸载 V2RayA 和 V2Ray...${NC}"
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
    echo -e "${GREEN}卸载完成。${NC}"

    # 删除自身
    echo -e "${GREEN}删除脚本自身...${NC}"
    rm -- "$0"

elif [ "$choice" == "3" ]; then
    # 更改 V2RayA 密码
    sudo v2raya --reset-password 
    echo -e "${GREEN}密码更改完成正在重启V2。${NC}"
    sudo systemctl restart v2raya.service


else
    echo "无效的选择。请运行脚本并选择 1, 2 或 3。"
fi
