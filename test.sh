#!/bin/bash

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
    if [ $? -ne 0 ];then
        resolve_dns_issue
        eval "$cmd"
    fi
}

# 提示返回导航页的函数
prompt_return_to_menu() {
    echo -e "${BLUE}输入0返回导航页: ${NC}"
    read -p "" choice
    if [ "$choice" == "0" ]; then
        return_to_menu
    fi
}

# 安装 V2RayA 的函数
install_v2raya() {
    echo -e "${GREEN}请选择 V2RayA 和 V2Ray 的安装方式：${NC}"
    echo -e "${GREEN}1. 源在线安装${NC}"
    echo -e "${GREEN}2. 本地或github安装${NC}"
    read -p "输入选择的编号 (1/2): " install_method

    if [ "$install_method" == "1" ];then
        # 在线安装 V2RayA 和 V2Ray
        echo "正在安装 V2RayA 和 V2Ray..."
        execute_command "wget -qO - https://apt.v2raya.org/key/public-key.asc | sudo tee /etc/apt/keyrings/v2raya.asc"
        echo "deb [signed-by=/etc/apt/keyrings/v2raya.asc] https://apt.v2raya.org/ v2raya main" | sudo tee /etc/apt/sources.list.d/v2raya.list
        sudo apt update
        sudo apt install -y v2raya v2ray
        sudo systemctl start v2raya.service
        echo "安装完成。"
    elif [ "$install_method" == "2" ];then
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
    if [ "$proxy_setup" == "y" ];then
        # 提示用户选择要安装的版本
        echo -e "${GREEN}请选择要安装的版本：${NC}"
        echo -e "${GREEN}1. 5.4${NC}"
        echo -e "${GREEN}2. 6.1${NC}"
        read -p "输入选择的版本编号 (1/2): " kernel_choice

        # 根据用户选择替换 KERNEL=
        if [ "$kernel_choice" == "1" ];then
            kernel_version="5.4"
        elif [ "$kernel_choice" == "2" ];then
            kernel_version="6.1"
        else
            echo "无效的选择。请重新运行脚本并选择 1 或 2。"
            return
        fi

        # 执行代理设置命令，并替换 KERNEL=
        bash -c "wget -O - https://www.openmptcprouter.com/server/debian-x86_64.sh | KERNEL=\"$kernel_version\" sh"
    fi

    prompt_return_to_menu
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

modify_host() {
    # 备份 /etc/hosts 文件
    if [ ! -f /etc/host_back ];then
        sudo cp /etc/hosts /etc/host_back
        echo "Backup created: /etc/host_back"
    else
        echo "Backup already exists: /etc/host_back"
    fi

    # 修改 /etc/hosts 文件
    # 检查是否已安装curl命令
    if ! command -v curl &> /dev/null;then
        echo -e "${RED}检测到 没有安装curl，正在安装...${NC}"
        sudo apt-get install -y curl
    fi
    execute_command "sudo sh -c 'sed -i \"/# GitHub520 Host Start/Q\" /etc/hosts && curl https://raw.hellogithub.com/hosts >> /etc/hosts'"
    echo "/etc/hosts 文件修改完成..."

    # 创建定时任务文件
    local cron_file="/tmp/cron_job"
    local cron_job="0 * * * * /usr/bin/curl -s https://raw.hellogithub.com/hosts >> /etc/hosts; echo \$(date) >> /tmp/cron_count.txt"

    # 清理任何已有的定时任务
    (crontab -l 2>/dev/null | grep -v "curl -s https://raw.hellogithub.com/hosts" | crontab -)

    # 设置定时任务
    echo "$cron_job" > $cron_file
    crontab $cron_file

    echo -e "${GREEN}定时任务已设置，每小时运行一次，总共更新2次host后，自动关闭更新。${NC}"

    # 检查是否已安装at命令
    if ! command -v at &> /dev/null;then
        echo -e "${RED}检测到 没有安装at，正在安装...${NC}"
        sudo apt-get install -y at
    fi

    # 使用 at 命令在 2 小时后移除定时任务
    echo '(crontab -l 2>/dev/null | grep -v "curl -s https://raw.hellogithub.com/hosts" | crontab -)' | at now + 2 hours

    prompt_return_to_menu
}

# 安装 Docker 的函数
install_docker() {
    echo "更新依赖..."
    sudo apt update

    echo "安装必要依赖..."
    sudo apt install -y curl software-properties-common

    echo "添加官方密钥..."
    curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/debian/gpg | sudo apt-key add -

    echo "安装 Docker 源镜像..."
    sudo add-apt-repository "https://mirrors.ustc.edu.cn/docker-ce/linux/debian $(lsb_release -cs) stable"

    echo "安装 Docker 与 Docker Compose..."
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    sudo systemctl status docker

    echo "设置开机启动 Docker..."
    sudo systemctl enable docker
    echo "Docker 设置完毕"

    docker version
    docker-compose version

    # 创建目录（如果不存在） /etc/docker/daemon.json
    sudo mkdir -p /etc/docker  

    # 提示用户输入 Docker 反向代理地址
    echo -n "请输入 Docker 代理地址，末尾带上 /（如果有多个，用逗号分隔）: "
    read registry_mirrors

    # 处理用户输入，确保每个地址都带有双引号
    IFS=',' read -ra ADDR <<< "$registry_mirrors"
    formatted_mirrors=$(printf '"%s",' "${ADDR[@]}")
    formatted_mirrors=${formatted_mirrors%,} # 去掉最后一个逗号

    # 将用户输入写入 daemon.json 文件
    sudo tee /etc/docker/daemon.json <<-EOF
    {
      "registry-mirrors": [${formatted_mirrors}]  
    } 
EOF

    sudo systemctl daemon-reload  
    sudo systemctl restart docker

    prompt_return_to_menu
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

    # 使用子 Shell 执行命令以避免导航页循环
    (execute_command "wget -O - https://www.openmptcprouter.com/server/debian-x86_64.sh | KERNEL=\"$kernel_version\" sh")
    echo "安装完毕，请重启服务器，重启后端口为：${GREEN}65222${NC}"

    prompt_return_to_menu
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
      -p 80:2022 -p 1935:1935 -p 8000:8000/udp -p 10080:10080/udp \
      ossrs/oryx:5

    if [ $? -eq 0 ]; then
        echo "SRS 安装并启动成功。"
    else
        echo -e "${RED}SRS 安装或启动失败。${NC}"
    fi

    # 返回选择页面
    prompt_return_to_menu
}

# 返回主菜单的函数
return_to_menu() {
    echo -e "${BLUE}----------返回主菜单----------${NC}"
    echo -e "${GREEN}请选择操作：${NC}"
    echo -e "${GREEN}1. 安装 V2RayA${NC}"
    echo -e "${GREEN}2. 卸载 V2RayA${NC}"
    echo -e "${GREEN}3. 修改 HOST${NC}"
    echo -e "${GREEN}4. 安装 SRT${NC}"
    echo -e "${GREEN}5. 安装 SRS${NC}"
    echo -e "${GREEN}0. 退出${NC}"
    read -p "输入选择的编号 (0-5): " choice

    echo "你选择了：$choice" # 添加调试信息
    case "$choice" in
        1)
            install_v2raya
            ;;
        2)
            uninstall_v2raya
            ;;
        3)
            modify_host
            ;;
        4)
            install_srt
            ;;
        5)
            install_srs
            ;;
        0)
            echo "退出脚本。"
            exit 0
            ;;
        *)
            echo "无效的选择。请重新选择 0 到 5 之间的编号。"
            return_to_menu
            ;;
    esac
}

# 启动脚本并显示主菜单
return_to_menu
