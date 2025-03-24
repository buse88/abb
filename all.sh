#!/bin/bash

# 只在 Debian 12 amd64 机器测试，功能有 V2RayA、HOST、SRT、SRS、Docker 在 CN 网络安装

echo -e "版本 V3.2"
# ANSI 颜色码定义
RED='\033[0;31m'    # 红色
GREEN='\033[0;32m'  # 绿色
BLUE='\033[0;34m'   # 蓝色
YELLOW='\033[0;33m' # 黄色
NC='\033[0m'        # 无颜色（RESET）

# 检查是否通过管道运行
if [ -t 0 ]; then
    INTERACTIVE=1  # 终端模式
else
    INTERACTIVE=0  # 管道模式
fi

# 处理 curl: (6) Could not resolve host 错误的函数
resolve_dns_issue() {
    echo -e "${RED}检测到 DNS 解析错误，请检查网络连接和 DNS 设置。${NC}"
    echo -e "${RED}您可以尝试手动将 DNS 服务器设置为 223.5.5.5 或 119.29.29.29。${NC}"
    echo -e "${RED}例如，编辑 /etc/resolv.conf 并添加：${NC}"
    echo -e "${RED}nameserver 223.5.5.5${NC}"
    echo -e "${RED}nameserver 119.29.29.29${NC}"
    exit 1
}

# 封装 curl 和 wget 命令，自动处理 DNS 解析错误并重试
execute_command() {
    local cmd="$1"
    eval "$cmd"
    if [ $? -ne 0 ]; then
        resolve_dns_issue
    fi
}

# 检查系统架构并下载相应的文件
check_architecture_and_download() {
    ARCH=$(uname -m)
    if [ "$ARCH" == "x86_64" ]; then
        echo "检测到系统架构为 amd64"
        execute_command "wget -P /tmp https://gitee.com/t88t/test/releases/download/v2/installer_debian_amdx64_2.2.5.5.deb"
        execute_command "wget -P /tmp https://gitee.com/t88t/test/releases/download/v2/v2ray-linux-amd64.zip"
    elif [ "$ARCH" == "aarch64" ]; then
        echo "检测到系统架构为 arm64"
        execute_command "wget -P /tmp https://gitee.com/t88t/test/releases/download/v2/installer_debian_arm64_2.2.5.5.deb"
        execute_command "wget -P /tmp https://gitee.com/t88t/test/releases/download/v2/v2ray-linux-arm64-v8a.zip"
    else
        echo -e "${RED}未支持的系统架构: $ARCH${NC}"
        exit 1
    fi
}

# 安装 V2RayA 的函数
install_v2raya() {
    echo -e "${RED}----------V2和Host 二选一即可，不用都安装----------${NC}"
    echo -e "${GREEN}请选择 V2RayA 和 V2Ray 的安装方式：${NC}"
    echo -e "${GREEN}1. 源在线安装${NC}"
    echo -e "${GREEN}2. 本地或 Gitee 安装${NC}"
    read -p "输入选择的编号 (1/2): " install_method < /dev/tty

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
        echo "若是本地安装，请先将 deb 文件和 zip 文件放入 /tmp 目录"
        check_architecture_and_download
        sudo apt install -y /tmp/installer_debian_amdx64_2.2.5.5.deb
        unzip /tmp/v2ray-linux-amd64.zip -d /tmp/v2ray
        sudo mkdir -p /usr/local/share/v2ray
        sudo cp /tmp/v2ray/*dat /usr/local/share/v2ray
        sudo install -Dm755 /tmp/v2ray/v2ray /usr/local/bin/v2ray
        sudo rm -rf /tmp/v2ray /tmp/v2ray-linux-amd64.zip
        sudo systemctl start v2raya.service
        echo "本地安装完成。"
    else
        echo "无效的选择。请重新运行脚本并选择 1 或 2。"
        return
    fi

    # 提示用户完成代理设置
    read -p "是否已完成代理设置？(输入 'y' 完成): " proxy_setup < /dev/tty
    if [ "$proxy_setup" == "y" ]; then
        # 提示用户选择要安装的版本
        echo -e "${GREEN}请选择要安装的版本：${NC}"
        echo -e "${GREEN}1. 5.4${NC}"
        echo -e "${GREEN}2. 6.1${NC}"
        read -p "输入选择的版本编号 (1/2): " kernel_choice < /dev/tty

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
        execute_command "wget -O - https://www.openmptcprouter.com/server/debian-x86_64.sh | KERNEL=\"${kernel_version}\" sh"
    fi
    # 返回选择页面
    return_to_menu
}

# 更换软件源的函数
change_sources() {
    echo -e "${GREEN}请选择要更换的软件源：${NC}"
    echo -e "${GREEN}1. 教育网源${NC}"
    echo -e "${GREEN}2. 阿里云源${NC}"
    echo -e "${GREEN}3. 清华源${NC}"
    read -p "输入选择的编号 (1/2/3): " source_choice < /dev/tty

    # 定义不同源的 URL
    case "$source_choice" in
        1)
            NEW_SOURCES_URL="https://gitee.com/t88t/test/raw/master/debian12-edu-sources.list"
            ;;
        2)
            NEW_SOURCES_URL="https://gitee.com/t88t/test/raw/master/debian12-aliyun-sources.list"
            ;;
        3)
            NEW_SOURCES_URL="https://gitee.com/t88t/test/raw/master/debian12-tsinghua-sources.list"
            ;;
        *)
            echo "无效的选择，请重新运行脚本并选择 1/2/3。"
            return
            ;;
    esac

    # 检查是否已经存在备份文件
    if [ ! -f /etc/apt/sources.list.bak ]; then
        echo "正在备份当前的 sources.list 到 sources.list.bak..."
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    else
        echo "已存在备份文件 sources.list.bak，跳过备份。"
    fi

    # 下载新的 sources.list
    echo "正在下载新的 sources.list..."
    execute_command "wget -O /tmp/debian-sources.list $NEW_SOURCES_URL"

    # 替换当前的 sources.list
    echo "正在替换当前的 sources.list..."
    sudo mv /tmp/debian-sources.list /etc/apt/sources.list

    # 更新软件包列表
    echo "正在更新软件包列表..."
    sudo apt update
    echo "软件源更换完成。"
    # 返回选择页面
    return_to_menu
}

# 卸载 V2RayA 的函数
uninstall_v2raya() {
    echo "正在卸载 V2RayA 和 V2Ray..."
    sudo systemctl stop v2raya.service
    sudo apt remove --purge -y v2raya v2ray
    sudo rm -f /etc/apt/sources.list.d/v2raya.list
    sudo rm -f /etc/apt/keyrings/v2raya.asc
    sudo rm -rf /etc/v2raya
    sudo rm -rf /etc/v2ray
    sudo rm -rf /usr/local/etc/v2ray
    sudo rm -rf ~/.config/v2raya
    sudo rm -rf ~/.config/v2ray
    sudo apt update
    echo "卸载完成。"
    echo "请手动删除脚本文件（如果需要）。"
}

# 更新 GitHub Hosts 的函数
modify_host() {
    echo -e "${RED}----------提示：V2和Host 二选一即可，不用都安装----------${NC}"

    # 备份 /etc/hosts 文件
    if [ ! -f /etc/host_back ]; then
        sudo cp /etc/hosts /etc/host_back
        echo "备份创建: /etc/host_back"
    else
        echo "备份已存在: /etc/host_back"
    fi

    # 检查并安装 curl（如果未安装）
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}未检测到 curl，正在安装...${NC}"
        sudo apt update
        sudo apt install -y curl
        if [ $? -ne 0 ]; then
            echo -e "${RED}安装 curl 失败，请手动安装 curl 后重试。${NC}"
            return
        fi
        echo -e "${GREEN}curl 安装成功，继续执行...${NC}"
    fi

    # 检查并安装 jq（如果未安装）
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}未检测到 jq，正在安装...${NC}"
        sudo apt update
        sudo apt install -y jq
        if [ $? -ne 0 ]; then
            echo -e "${RED}安装 jq 失败，请手动安装 jq 后重试。${NC}"
            return
        fi
        echo -e "${GREEN}jq 安装成功，继续执行...${NC}"
    fi

    echo -e "${YELLOW}正在更新 GitHub 的 IP 地址...${NC}"
    # 从 GitHub API 获取 IP 地址
    GITHUB_IPS=$(curl -s https://api.github.com/meta | jq -r '.web[]')
    if [[ -z "$GITHUB_IPS" ]]; then
        echo -e "${RED}无法获取 GitHub 最新 IP，跳过更新 /etc/hosts${NC}"
        return_to_menu
        return
    fi

    # 移除现有的 GitHub 相关条目
    for domain in "github.com" "objects.githubusercontent.com" "raw.githubusercontent.com"; do
        sudo sed -i "/$domain/d" /etc/hosts
    done

    # 添加新的 IP 和域名映射
    for ip in $GITHUB_IPS; do
        echo "$ip github.com" | sudo tee -a /etc/hosts > /dev/null
        echo "$ip objects.githubusercontent.com" | sudo tee -a /etc/hosts > /dev/null
        echo "$ip raw.githubusercontent.com" | sudo tee -a /etc/hosts > /dev/null
    done

    echo -e "${GREEN}GitHub 的 IP 地址已更新！${NC}"
    # 返回选择页面
    return_to_menu
}

# 安装 Docker 的函数
install_docker() {
    echo "更新依赖..."
    sudo apt update

    echo "安装必要依赖..."
    sudo apt install -y curl software-properties-common

    echo "添加官方密钥..."
    execute_command "curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | sudo apt-key add -"

    echo "安装 Docker 源镜像..."
    sudo add-apt-repository -y "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/debian $(lsb_release -cs) stable"

    echo "安装 Docker 与 Docker Compose..."
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose

    echo "启动 Docker..."
    sudo systemctl start docker
    sudo systemctl status docker

    echo "设置开机启动 Docker..."
    sudo systemctl enable docker
    echo "Docker 设置完毕"

    docker version
    docker-compose version

    # 创建目录（如果不存在） /etc/docker/daemon.json
    sudo mkdir -p /etc/docker

    # 提供默认的 Docker 镜像源
    default_mirrors='"https://registry.docker-cn.com","https://docker.mirrors.ustc.edu.cn"'

    # 提示用户输入 Docker 反向代理地址
    echo -n "请输入 Docker 代理地址，末尾带上 /（如果有多个，用逗号分隔），或按 Enter 使用默认值: " < /dev/tty
    read registry_mirrors < /dev/tty

    if [ -z "$registry_mirrors" ]; then
        formatted_mirrors=$default_mirrors
    else
        # 处理用户输入，确保每个地址都带有双引号
        IFS=',' read -ra ADDR <<< "$registry_mirrors"
        formatted_mirrors=$(printf '"%s",' "${ADDR[@]}")
        formatted_mirrors=${formatted_mirrors%,} # 去掉最后一个逗号
    fi

    # 将用户输入写入 daemon.json 文件
    sudo tee /etc/docker/daemon.json <<-EOF
    {
      "registry-mirrors": [$formatted_mirrors]
    }
EOF

    sudo systemctl daemon-reload
    sudo systemctl restart docker
}

# 安装 SRT 的函数
install_srt() {
    echo -e "${GREEN}请选择要安装的版本：${NC}"
    echo -e "${GREEN}1. 5.4${NC}"
    echo -e "${GREEN}2. 6.1${NC}"
    read -p "输入选择的版本编号 (1/2): " kernel_choice < /dev/tty

    if [ "$kernel_choice" == "1" ]; then
        kernel_version="5.4"
    elif [ "$kernel_choice" == "2" ]; then
        kernel_version="6.1"
    else
        echo "无效的选择。请重新运行脚本并选择 1 或 2。"
        return
    fi

    execute_command "wget -O - https://www.openmptcprouter.com/server/debian-x86_64.sh | KERNEL=\"${kernel_version}\" sh"
    echo "看到这个才安装成功 You need to reboot to enable MPTCP, shadowsocks, glorytun and shorewall"
    echo "若安装成功，请重启服务器，重启后 ssh 端口为：65222"
}

# 安装 SRS 的函数
install_srs() {
    # 检查 Docker 是否已安装
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker 未安装，正在安装 Docker...${NC}"
        install_docker
    fi

    echo "正在安装 SRS..."
    docker run --restart always -d -it --name oryx0 -v $HOME/data0:/data \
      -p 2021:2022 -p 2443:2443 -p 1935:1935 -p 8088:8000/udp -p 10080:10080/udp \
      ossrs/oryx:5

    if [ $? -eq 0 ]; then
        echo "SRS 安装并启动成功。后台地址 http://ip:2021"
    else
        echo -e "${RED}SRS 安装或启动失败。${NC}"
    fi

    # 返回选择页面
    return_to_menu
}

# 返回主菜单的函数
return_to_menu() {
    if [ "$INTERACTIVE" -eq 0 ]; then
        echo -e "${YELLOW}检测到管道模式运行（例如 wget -qO- | bash），此脚本需要交互式输入。${NC}"
        echo -e "${YELLOW}请下载脚本后本地运行：${NC}"
        echo -e "${YELLOW}  wget -O setup.sh <脚本URL>${NC}"
        echo -e "${YELLOW}  chmod +x setup.sh${NC}"
        echo -e "${YELLOW}  sudo ./setup.sh${NC}"
        exit 1
    fi

    echo -e "${GREEN}请选择操作：${NC}"
    echo -e "${GREEN}1. 更换软件源${NC}"
    echo -e "${GREEN}2. 修改 HOST${NC}"
    echo -e "${GREEN}3. 安装 SRT${NC}"
    echo -e "${GREEN}4. 安装 SRS (Docker 版)${NC}"
    echo -e "${GREEN}5. 安装 V2RayA${NC}"
    echo -e "${GREEN}6. 卸载 V2RayA${NC}"
    echo -e "${GREEN}0. 退出${NC}"
    read -p "输入选择的编号 (0-6): " choice < /dev/tty

    case "$choice" in
        1)
            change_sources
            ;;
        2)
            modify_host
            ;;
        3)
            install_srt
            ;;
        4)
            install_srs
            ;;
        5)
            install_v2raya
            ;;
        6)
            uninstall_v2raya
            ;;
        0)
            echo "退出脚本。"
            exit 0
            ;;
        *)
            echo "无效的选择。请重新选择 0 到 6 之间的编号。"
            return_to_menu
            ;;
    esac
}

# 启动脚本并显示主菜单
return_to_menu
