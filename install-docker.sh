#!/bin/bash  

# 安装Docker所需的依赖  
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common  
  
# 添加Docker的官方GPG密钥  
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -  
  
# 设置Docker的稳定版本存储库  
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian bookworm stable"  
  
# 再次更新软件包列表  
sudo apt-get update  
  
# 安装Docker CE  
sudo apt-get install -y docker-ce docker-ce-cli containerd.io  
  
# 验证Docker是否安装成功  
sudo docker --version  
  
# 启动Docker服务  
sudo systemctl start docker  
  
# 设置Docker服务开机自启  
sudo systemctl enable docker  
  
echo "Docker安装并启动成功！"
