# baidupan Skill

description: 百度网盘 API 操作：文件列表、搜索、上传、下载、管理（复制/移动/删除/重命名）、用户信息。包含 BaiduPCS-Go 增强功能。
author: gochange

metadata: {"clawdbot":{"emoji":"☁️","requires":{"bins":["curl","jq","go","git"],"env":["BAIDU_PAN_ACCESS_TOKEN"]},"primaryEnv":"BAIDU_PAN_ACCESS_TOKEN"}}

通过百度网盘开放 API 管理云端文件。包含两个层面的功能：轻量级API脚本和BaiduPCS-Go增强工具。

## 功能

- 文件操作：列出、搜索、上传、下载
- 文件管理：复制、移动、删除、重命名
- 目录操作：创建目录
- 用户信息：获取容量等
- 支持 BaiduPCS-Go 增强功能

## 配置

1. 获取百度网盘访问令牌：
   - 参考：https://pan.baidu.com/union/document/official
   - 设置环境变量：`BAIDU_PAN_ACCESS_TOKEN=your_access_token`

2. 可选：安装 BaiduPCS-Go 增强工具：
   - 运行 `{baseDir}/install_baidupcs_go.sh`

## 使用方法

### 使用原生API脚本

```bash
# 列出根目录文件
{baseDir}/scripts/baidupan.sh ls /

# 搜索文件
{baseDir}/scripts/baidupan.sh search keyword

# 下载文件
{baseDir}/scripts/baidupan.sh download /path/on/baidu/disk /local/path

# 复制文件
{baseDir}/scripts/baidupan.sh copy /source/path /target/path

# 移动文件
{baseDir}/scripts/baidupan.sh mv /source/path /target/path

# 删除文件
{baseDir}/scripts/baidupan.sh rm /path/to/file

# 创建目录
{baseDir}/scripts/baidupan.sh mkdir /path/to/new/directory

# 上传文件（使用BaiduPCS-Go）
{baseDir}/scripts/baidupan.sh upload /path/to/local/file "/path/on/baidu/disk"
```

注意：上传功能依赖于BaiduPCS-Go工具，因为原生API可能存在上传限制。确保已按上述方式安装BaiduPCS-Go。

### 使用 BaiduPCS-Go

```bash
# 查看网盘容量
BaiduPCS-Go quota

# 列出目录
BaiduPCS-Go ls /

# 上传文件
BaiduPCS-Go upload /path/to/local/file /remote/path/

# 下载文件
BaiduPCS-Go download /remote/path/file /local/path/

# 创建目录
BaiduPCS-Go mkdir /path/to/new/directory

# 移动/重命名文件
BaiduPCS-Go mv /path/to/source /path/to/destination
```

## BaiduPCS-Go 安装与配置

BaiduPCS-Go 是一个功能完整的百度网盘命令行客户端，提供更全面的功能。

### 安装 BaiduPCS-Go

```bash
# 安装必要依赖
sudo apt-get install -y golang-go git

# 设置Go环境变量
export GOPATH=$HOME/go
export GOCACHE=$HOME/.cache/go-build
mkdir -p $GOPATH $GOCACHE

# 克隆并构建 BaiduPCS-Go
cd /tmp && git clone https://github.com/qjfoidnh/BaiduPCS-Go.git
cd /tmp/BaiduPCS-Go

# 修改 go.mod 以兼容当前 Go 版本
sed -i 's/go 1.23/go 1.22/' go.mod

# 构建二进制文件
go build -o BaiduPCS-Go

# 安装到系统路径
sudo mv /tmp/BaiduPCS-Go/BaiduPCS-Go /usr/local/bin/
sudo chmod +x /usr/local/bin/BaiduPCS-Go
```

### 使用 BDUSS 和 STOKEN 登录

```bash
# 使用 BDUSS 和 STOKEN 登录
BaiduPCS-Go login --bduss=YOUR_BDUSS --stoken=YOUR_STOKEN

# 或者使用 accessToken
BaiduPCS-Go setastoken YOUR_ACCESS_TOKEN
```

## 使用示例

### 使用原生API脚本
```bash
# 列出根目录文件
./scripts/baidupan.sh ls /

# 搜索文件
./scripts/baidupan.sh search "*.txt"

# 下载文件
./scripts/baidupan.sh download "/My Documents/file.txt" ./local_file.txt

# 创建目录
./scripts/baidupan.sh mkdir "/New Folder"

# 删除文件
./scripts/baidupan.sh rm "/Old File.txt"

# 上传文件
./scripts/baidupan.sh upload /path/to/local/file "/path/on/baidu/disk"
```

### 使用 BaiduPCS-Go 的增强功能
```bash
BaiduPCS-Go quota                           # 查看容量
BaiduPCS-Go ls /                            # 列出文件
BaiduPCS-Go upload local_file /path/        # 上传文件
BaiduPCS-Go download /path/file local_path  # 下载文件
BaiduPCS-Go mkdir /path/to/dir              # 创建目录
BaiduPCS-Go mv /path/old /path/new          # 移动/重命名
BaiduPCS-Go rm /path/to/file                # 删除文件
BaiduPCS-Go tree /path/                     # 树状显示目录
```

## 注意事项

- 上传功能可能需要STOKEN才能正常工作，仅BDUSS或访问令牌可能不足以完成上传操作
- BaiduPCS-Go 提供了更稳定和全面的百度网盘访问能力