# debian国内源安装docker

# 更新索引包
sudo apt update
# 安装设置仓库必须的工具
sudo apt update && sudo apt install -y ca-certificates curl gnupg lsb-release
# 安装HTTPS支持包
sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
# 添加软件源的GPG密钥
sudo curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/aliyun-docker.gpg
# 添加Docker软件源
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/aliyun-docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# 安装
sudo apt update
sudo apt install -y docker-ce
# 启动docker
sudo service docker start
# 重启docker服务
sudo systemctl restart docker
# docker设置开机启动
sudo systemctl start docker


