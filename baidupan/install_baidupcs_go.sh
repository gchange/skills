#!/bin/bash
# 安装 BaiduPCS-Go 的脚本

set -e  # 遇到错误时停止执行

echo "开始安装 BaiduPCS-Go..."

# 检查是否已安装 go
if ! command -v go &> /dev/null; then
    echo "正在安装 Go..."
    sudo apt-get update
    sudo apt-get install -y golang-go
else
    echo "Go 已安装"
fi

# 检查是否已安装 git
if ! command -v git &> /dev/null; then
    echo "正在安装 Git..."
    sudo apt-get install -y git
else
    echo "Git 已安装"
fi

# 设置 Go 环境变量
export GOPATH=$HOME/go
export GOCACHE=$HOME/.cache/go-build
mkdir -p $GOPATH $GOCACHE

echo "克隆 BaiduPCS-Go 源码..."
cd /tmp
if [ -d "BaiduPCS-Go" ]; then
    rm -rf BaiduPCS-Go
fi

git clone https://github.com/qjfoidnh/BaiduPCS-Go.git
cd /tmp/BaiduPCS-Go

# 修改 go.mod 以兼容当前 Go 版本
if grep -q "go 1.23" go.mod; then
    sed -i 's/go 1.23/go 1.22/' go.mod
    echo "已修改 go.mod 以兼容 Go 1.22"
fi

echo "正在构建 BaiduPCS-Go..."
go build -o BaiduPCS-Go

echo "安装 BaiduPCS-Go 到系统路径..."
sudo mv /tmp/BaiduPCS-Go/BaiduPCS-Go /usr/local/bin/
sudo chmod +x /usr/local/bin/BaiduPCS-Go

echo "BaiduPCS-Go 安装完成！"
echo ""
echo "使用方法："
echo "1. 使用 BDUSS 和 STOKEN 登录："
echo "   BaiduPCS-Go login --bduss=YOUR_BDUSS --stoken=YOUR_STOKEN"
echo ""
echo "2. 或者使用 accessToken："
echo "   BaiduPCS-Go setastoken YOUR_ACCESS_TOKEN"
echo ""
echo "3. 查看帮助："
echo "   BaiduPCS-Go -h"