# debian国内源安装docker

echo "更新依赖..."
sudo apt update

echo "安装必要依赖..."
sudo apt install curl
sudo apt install software-properties-common

echo "添加官方密钥..."
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/debian/gpg | sudo apt-key add -

echo "安装docker源镜像..."
sudo add-apt-repository "https://mirrors.ustc.edu.cn/docker-ce/linux/debian $(lsb_release -cs) stable"

echo "安装docker与docker-compose..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "启动docker..."
systemctl start docker
#查看docker启动情况
systemctl status docker

echo "设置开机启动docker..."
sudo systemctl enable docker
echo "docker设置完毕"
docker version
docker-compose version

# 创建目录（如果不存在） /etc/docker/daemon.json
sudo mkdir -p /etc/docker  

# 提示用户输入 docker反代地址
echo -n "请输入 docker代理地址，末尾带上 /例：https://1.com/（如果有多个，用逗号分隔）: "
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


