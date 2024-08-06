#!/bin/bash  
  
# 检查是否以root用户运行  
if [ "$(id -u)" != "0" ]; then  
   echo "此脚本必须以root权限运行" 1>&2  
   exit 1  
fi  
  
# 备份原始的sshd_config文件（如果备份文件不存在）  
if ! [ -f /etc/ssh/sshd_config.backup.$(date +%Y%m%d) ]; then  
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)  
    echo "sshd_config文件已备份。"  
fi  
  
# 设置PermitRootLogin为yes  
# 使用sed命令直接设置PermitRootLogin的值，无论它之前是什么  
sed -i '/^PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config  
# 如果PermitRootLogin行不存在，则添加它  
if ! grep -q '^PermitRootLogin' /etc/ssh/sshd_config; then  
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config  
fi  
  
# 重启SSH服务以应用更改  
systemctl restart sshd  
# 或者，如果你的系统使用init.d  
# /etc/init.d/ssh restart  
  
echo "SSH配置已更新，允许root用户通过密码登录。SSH服务已重启。"
