#!/bin/bash

# 定义新源的URL
NEW_SOURCES_URL="https://githubdw.8080k.eu.org/https://raw.githubusercontent.com/buse88/abb/main/debian12-sources.list"

# 备份当前的sources.list
if [ -e /etc/apt/sources.list ]; then
    echo "正在备份当前的sources.list到sources.list.bak..."
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
else
    echo "/etc/apt/sources.list不存在，跳过备份。"
fi

# 下载新的sources.list
echo "正在下载新的sources.list..."
wget -O /tmp/debian12-sources.list $NEW_SOURCES_URL

# 检查下载是否成功
if [ $? -ne 0 ]; then
    echo "下载新的sources.list失败，请检查URL是否正确。"
    exit 1
fi

# 替换当前的sources.list
echo "正在替换当前的sources.list..."
sudo mv /tmp/debian12-sources.list /etc/apt/sources.list

# 更新软件包列表
echo "正在更新软件包列表..."
sudo apt update

echo "软件源更换完成。"
