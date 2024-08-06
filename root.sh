#!/bin/bash  
  
# 检查是否以root用户运行  
if [ "$(id -u)" != "0" ]; then  
   echo "此脚本必须以root权限运行" 1>&2  
   exit 1  
fi  
  
# 检查sshd_config的备份文件是否已经存在  
if [ -f /etc/ssh/sshd_config.backup.* ]; then  
    echo "sshd_config的备份文件已存在，跳过备份步骤。"  
else  
    # 备份原始的sshd_config文件  
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)  
    echo "sshd_config文件已备份。"  
fi  
  
# 启用root通过SSH登录  
# 使用sed命令查找并取消注释PermitRootLogin行，或者如果行不存在则添加它  
# 注意：根据你的sshd_config文件的具体内容，可能需要调整这个命令  
sed -i '/^#PermitRootLogin/s/^#//' /etc/ssh/sshd_config  
# 如果上述命令没有修改文件（即PermitRootLogin行不存在），则添加它  
if ! grep -q '^PermitRootLogin' /etc/ssh/sshd_config; then  
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config  
fi  
  
# 重启SSH服务以应用更改  
# 注意：根据你的系统，服务名称可能是sshd或ssh  
systemctl restart sshd  
# 如果你的系统使用的是较旧的init.d系统，请使用以下命令  
# /etc/init.d/ssh restart  
  
echo "SSH配置已更新，允许root用户登录。SSH服务已重启。"
