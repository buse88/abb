#!/bin/bash

# 支持管道执行的版本
# 用法示例：
# curl -s https://raw.githubusercontent.com/your-repo/all.sh | bash -s -- -s edu -h -v2 -d -srt 5.4 -srs
# 或者直接执行显示菜单：wget -qO- https://raw.githubusercontent.com/your-repo/all_pipe.sh | bash

# ANSI 颜色码定义
RED='\033[0;31m'    # 红色
GREEN='\033[0;32m'  # 绿色
BLUE='\033[0;34m'   # 蓝色
NC='\033[0m'        # 无颜色

# 如果没有参数，显示交互式菜单
if [ $# -eq 0 ]; then
    echo -e "${GREEN}请选择操作：${NC}"
    echo -e "${GREEN}1. 更换软件源${NC}"
    echo -e "${GREEN}2. 修改 HOST${NC}"
    echo -e "${GREEN}3. 安装 SRT${NC}"
    echo -e "${GREEN}4. 安装 SRS(docker版)${NC}"
    echo -e "${GREEN}5. 安装 V2${NC}"
    echo -e "${GREEN}6. 卸载 V2${NC}"
    echo -e "${GREEN}0. 退出${NC}"
    read -p "输入选择的编号 (0-6): " choice

    case "$choice" in
        1)
            echo -e "${GREEN}请选择要更换的软件源：${NC}"
            echo -e "${GREEN}1. 教育网源${NC}"
            echo -e "${GREEN}2. 阿里云源${NC}"
            echo -e "${GREEN}3. 清华源${NC}"
            read -p "输入选择的编号 (1/2/3): " source_choice
            case "$source_choice" in
                1) SOURCE="edu" ;;
                2) SOURCE="aliyun" ;;
                3) SOURCE="tsinghua" ;;
                *) echo "无效的选择" && exit 1 ;;
            esac
            ;;
        2)
            HOST=true
            ;;
        3)
            echo -e "${GREEN}请选择要安装的版本：${NC}"
            echo -e "${GREEN}1. 5.4${NC}"
            echo -e "${GREEN}2. 6.1${NC}"
            read -p "输入选择的版本编号 (1/2): " kernel_choice
            case "$kernel_choice" in
                1) SRT_VERSION="5.4" ;;
                2) SRT_VERSION="6.1" ;;
                *) echo "无效的选择" && exit 1 ;;
            esac
            ;;
        4)
            SRS=true
            ;;
        5)
            V2RAY=true
            ;;
        6)
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
            exit 0
            ;;
        0)
            echo "退出脚本。"
            exit 0
            ;;
        *)
            echo "无效的选择。请重新选择 0 到 6 之间的编号。"
            exit 1
            ;;
    esac
else
    # 处理命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--source)
                SOURCE="$2"
                shift 2
                ;;
            -h|--host)
                HOST=true
                shift
                ;;
            -v2|--v2ray)
                V2RAY=true
                shift
                ;;
            -d|--docker)
                DOCKER=true
                shift
                ;;
            -srt|--srt)
                SRT_VERSION="$2"
                shift 2
                ;;
            -srs|--srs)
                SRS=true
                shift
                ;;
            *)
                echo "未知参数: $1"
                exit 1
                ;;
        esac
    done
fi

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

# 更换软件源
if [ ! -z "$SOURCE" ]; then
    echo "正在更换软件源为: $SOURCE"
    case "$SOURCE" in
        "edu")
            NEW_SOURCES_URL="https://gitee.com/t88t/test/raw/master/debian12-edu-sources.list"
            ;;
        "aliyun")
            NEW_SOURCES_URL="https://gitee.com/t88t/test/raw/master/debian12-aliyun-sources.list"
            ;;
        "tsinghua")
            NEW_SOURCES_URL="https://gitee.com/t88t/test/raw/master/debian12-tsinghua-sources.list"
            ;;
        *)
            echo "无效的软件源选择"
            exit 1
            ;;
    esac

    if [ ! -f /etc/apt/sources.list.bak ]; then
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    fi

    wget -O /tmp/debian-sources.list "$NEW_SOURCES_URL"
    sudo mv /tmp/debian-sources.list /etc/apt/sources.list
    sudo apt update
fi

# 修改 HOST
if [ "$HOST" = true ]; then
    echo "正在修改 HOST..."
    if [ ! -f /etc/host_back ]; then
        sudo cp /etc/hosts /etc/host_back
    fi
    execute_command "sudo sh -c 'sed -i \"/# GitHub520 Host Start/Q\" /etc/hosts && curl https://raw.hellogithub.com/hosts >> /etc/hosts'"
fi

# 安装 V2RayA
if [ "$V2RAY" = true ]; then
    echo "正在安装 V2RayA..."
    execute_command "wget -qO - https://apt.v2raya.org/key/public-key.asc | sudo tee /etc/apt/keyrings/v2raya.asc"
    echo "deb [signed-by=/etc/apt/keyrings/v2raya.asc] https://apt.v2raya.org/ v2raya main" | sudo tee /etc/apt/sources.list.d/v2raya.list
    sudo apt update
    sudo apt install -y v2raya v2ray
    sudo systemctl start v2raya.service
fi

# 安装 Docker
if [ "$DOCKER" = true ]; then
    echo "正在安装 Docker..."
    sudo apt update
    sudo apt install -y curl software-properties-common
    curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg?spm=a2c6h.25603864.0.0.6c6c655f03u3cp | sudo apt-key add -
    sudo add-apt-repository -y "https://mirrors.ustc.edu.cn/docker-ce/linux/debian $(lsb_release -cs) stable"
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# 安装 SRT
if [ ! -z "$SRT_VERSION" ]; then
    echo "正在安装 SRT 版本: $SRT_VERSION"
    execute_command "wget -O - https://www.openmptcprouter.com/server/debian-x86_64.sh | KERNEL=\"$SRT_VERSION\" sh"
fi

# 安装 SRS
if [ "$SRS" = true ]; then
    echo "正在安装 SRS..."
    if ! command -v docker &> /dev/null; then
        echo "Docker 未安装，正在安装 Docker..."
        curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg?spm=a2c6h.25603864.0.0.6c6c655f03u3cp | sudo apt-key add -
        sudo add-apt-repository -y "https://mirrors.ustc.edu.cn/docker-ce/linux/debian $(lsb_release -cs) stable"
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose
        sudo systemctl start docker
        sudo systemctl enable docker
    fi
    
    docker run --restart always -d -it --name oryx0 -v $HOME/data0:/data \
      -p 2021:2022 -p 2443:2443 -p 1935:1935 -p 8088:8000/udp -p 10080:10080/udp \
      ossrs/oryx:5
fi

echo "所有操作已完成。"
