# debian国内源安装docker

# 更新索引包
sudo apt update
# 安装设置仓库必须的工具
echo "安装设置仓库必须的工具..."
sudo apt update && sudo apt install -y ca-certificates curl gnupg lsb-release
# 安装HTTPS支持包
echo "安装HTTPS支持包..."
sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
# 添加软件源的GPG密钥
echo "添加软件源的GPG密钥..."
sudo curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/aliyun-docker.gpg
# 添加Docker软件源
echo "添加Docker软件源..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/aliyun-docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# 安装
echo "升级软件源..."
sudo apt update
echo "安装docker-ce..."
sudo apt install -y docker-ce
# docker启动后台服务
echo "启动docker..."
sudo service docker start
sudo systemctl restart docker
sudo systemctl start docker
echo "查看 Docker 服务状态"
sudo systemctl status docker
echo "开机启动docker..."
sudo systemctl enable docker
echo "docker安装完毕"


