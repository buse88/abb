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

# 创建或更新 /etc/docker/daemon.json  
sudo mkdir -p /etc/docker  
sudo tee /etc/docker/daemon.json <<-'EOF'  
{  
  "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn/"]  
}  
EOF  
sudo systemctl daemon-reload  
sudo systemctl restart docker

