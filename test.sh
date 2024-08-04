#!/bin/bash

# 本代码仅测试 amd64 debian12系统，其他系统请根据代码自行更改
# ANSI 颜色码定义
RED='\033[0;31m'    # 红色
GREEN='\033[0;32m'  # 绿色
BLUE='\033[0;34m'   # 蓝色
NC='\033[0m'        # 无颜色

# 提示用户选择操作前的颜色提示
echo -e "${RED}----------1和3二选一即可，不用都安装----------${NC}"
    
# 处理 curl: (6) Could not resolve host 错误的函数
resolve_dns_issue() {
    echo -e "${RED}检测到 DNS 解析错误，正在修复...${NC}"
    if ! grep -q "nameserver 8.8.8.8" /etc/resolv.conf; then
        echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
    fi
    if ! grep -q "nameserver 8.8.4.4" /etc/resolv.conf; then
        echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf
    fi
    echo -e "${GREEN}DNS 解析错误已修复，继续执行...${NC}"
}

# 封装 curl 和 wget 命令，自动处理 DNS 解析错误并重试
execute_command() {
    local cmd="$1"
    eval "$cmd"
    if [ $? -ne 0 ]; then
        resolve_dns_issue
        eval "$cmd"
    fi
}

# 安装 V2RayA 的函数
install_v2raya() {
    echo -e "${GREEN}请选择 V2RayA 和 V2Ray 的安装方式：${NC}"
    echo -e "${GREEN}1. 源在线安装${NC}"
    echo -e "${GREEN}2. 本地或github安装${NC}"
    read -p "输入选择的编号 (1/2): " install_method

    if [ "$install_method" == "1" ]; then
        # 在线安装 V2RayA 和 V2Ray
        echo "正在安装 V2RayA 和 V2Ray..."
        execute_command "wget -qO - https://apt.v2raya.org/key/public-key.asc | sudo tee /etc/apt/keyrings/v2raya.asc"
        echo "deb [signed-by=/etc/apt/keyrings/v2raya.asc] https://apt.v2raya.org/ v2raya main" | sudo tee /etc/apt/sources.list.d/v2raya.list
        sudo apt update
        sudo apt install -y v2raya v2ray
        sudo systemctl start v2raya.service
        echo "安装完成。"
    elif [ "$install_method" == "2" ]; then
        # 本地安装 V2RayA 和 V2Ray
        echo "先把deb文件跟rar文件放入/opt目录"
        sudo apt install -y /opt/installer_debian_x64_2.2.5.5.deb
        cp /opt/v2ray-linux-64.zip /tmp
        pushd /tmp
        unzip v2ray-linux-64.zip -d ./v2ray
        mkdir -p /usr/local/share/v2ray && cp ./v2ray/*dat /usr/local/share/v2ray
        install -Dm755 ./v2ray/v2ray /usr/local/bin/v2ray
        rm -rf ./v2ray v2ray-linux-64.zip
        sudo systemctl start v2raya.service
        popd
        echo "本地安装完成。"
    else
        echo "无效的选择。请重新运行脚本并选择 1 或 2。"
        return
    fi

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
            return
        fi

        # 执行代理设置命令，并替换 KERNEL=
        execute_command "wget -O - https://www.openmptcprouter.com/server/debian-x86_64.sh | KERNEL=\"$kernel_version\" sh"
    fi
}

# 卸载 V2RayA 的函数
uninstall_v2raya() {
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
    echo "删除脚本自身..."
    rm -- "$0"
}

# 修改 HOST 的函数
modify_host() {
    # 备份 /etc/hosts 文件
    if [ ! -f /etc/host_back ]; then
        sudo cp /etc/hosts /etc/host_back
        echo "Backup created: /etc/host_back"
    else
        echo "Backup already exists: /etc/host_back"
    fi

    # 修改 /etc/hosts 文件
    execute_command "sudo sh -c 'sed -i \"/# GitHub520 Host Start/Q\" /etc/hosts && curl https://raw.hellogithub.com/hosts >> /etc/hosts'"
}

# 安装 SRT 的函数
install_srt() {
    echo -e "${GREEN}请选择要安装的版本：${NC}"
    echo -e "${GREEN}1. 5.4${NC}"
    echo -e "${GREEN}2. 6.1${NC}"
    read -p "输入选择的版本编号 (1/2): " kernel_choice

    if [ "$kernel_choice" == "1" ]; then
        kernel_version="5.4"
    elif [ "$kernel_choice" == "2" ]; then
        kernel_version="6.1"
    else
        echo "无效的选择。请重新运行脚本并选择 1 或 2。"
        return
    fi

    execute_command "wget -O - https://www.openmptcprouter.com/server/debian-x86_64.sh | KERNEL=\"$kernel_version\" sh"
}

# 安装 SRS 的函数
install_srs() {
    echo "正在安装SRS..."
    if docker ps -a | grep -q oryx; then
        echo -e "${RED}SRS容器（oryx）已存在。如果需要重新安装，请先删除现有容器。${NC}"
        return
    fi

    docker run --restart always -d -it --name oryx0 -it -v $HOME/data0:/data \
      -p 80:2022 -p 1935:1935 -p 8000:8000/udp -p 10080:10080/udp \
      registry.cn-hangzhou.aliyuncs.com/ossrs/oryx

    if [ $? -eq 0 ]; then
        echo "SRS安装并启动成功。"
    else
        echo -e "${RED}SRS安装或启动失败。${NC}"
    fi
}

while true; do
    # 提示用户选择操作
    echo -e "${GREEN}请选择操作：${NC}"
    echo -e "${GREEN}1. 安装 V2RayA${NC}"
    echo -e "${GREEN}2. 卸载 V2RayA${NC}"
    echo -e "${GREEN}3. 修改HOST${NC}"
    echo -e "${GREEN}4. 安装SRT${NC}"
    echo -e "${GREEN}5. 安装SRS${NC}"
    echo -e "${GREEN}0. 退出${NC}"
    echo -e "${BLUE}输入选择的编号 (0/1/2/3/4/5): ${NC}"
    read -p "" choice

    case $choice in
        0) echo "退出脚本"; exit 0 ;;
        1) install_v2raya ;;
        2) uninstall_v2raya ;;
        3) modify_host ;;
        4) install_srt ;;
        5) install_srs ;;
        *) echo "无效的选择。请重新选择。" ;;
    esac
done
