---
name: baidupan
description: 百度网盘 API 操作：文件列表、搜索、上传、下载、管理（复制/移动/删除/重命名）、用户信息。包含 BaiduPCS-Go 增强功能。
homepage: https://pan.baidu.com/union/doc
metadata: {"clawdbot":{"emoji":"☁️","requires":{"bins":["curl","jq","go","git"],"env":["BAIDU_PAN_ACCESS_TOKEN"]},"primaryEnv":"BAIDU_PAN_ACCESS_TOKEN"}}
---

# 百度网盘 (Baidu Pan)

通过百度网盘开放 API 管理云端文件。包含两个层面的功能：轻量级API脚本和BaiduPCS-Go增强工具。

## 配置

需要设置环境变量：
- `BAIDU_PAN_ACCESS_TOKEN` - 访问令牌（有效期 30 天）
- `BAIDU_PAN_APP_KEY` - 应用 AppKey（可选，用于刷新 token）
- `BAIDU_PAN_SECRET_KEY` - 应用 SecretKey（可选，用于刷新 token）
- `BAIDU_PAN_REFRESH_TOKEN` - 刷新令牌（可选，用于刷新 token）

### 获取 Access Token

1. 前往 https://pan.baidu.com/union/console/createapp 创建应用
2. 获取 AppKey 和 SecretKey
3. 授权获取 access_token：
```bash
# 打开浏览器访问授权链接
open "https://openapi.baidu.com/oauth/2.0/authorize?response_type=code&client_id=YOUR_APP_KEY&redirect_uri=oob&scope=basic,netdisk"

# 用授权码换取 token
curl -s "https://openapi.baidu.com/oauth/2.0/token?grant_type=authorization_code&code=CODE&client_id=APP_KEY&client_secret=SECRET_KEY&redirect_uri=oob" | jq
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

## 快速开始

### 使用原生API脚本

```bash
# 查看用户信息
{baseDir}/scripts/baidupan.sh user

# 查看网盘容量
{baseDir}/scripts/baidupan.sh quota

# 列出根目录文件
{baseDir}/scripts/baidupan.sh list /

# 搜索文件
{baseDir}/scripts/baidupan.sh search "关键词"

# 上传文件
{baseDir}/scripts/baidupan.sh upload /path/to/local/file "/path/on/baidu/disk"
```

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

## 常用命令

### 用户信息
```bash
{baseDir}/scripts/baidupan.sh user        # 用户信息
{baseDir}/scripts/baidupan.sh quota       # 网盘容量
```

### 文件列表
```bash
{baseDir}/scripts/baidupan.sh list /                    # 根目录
{baseDir}/scripts/baidupan.sh list /我的文档            # 指定目录
{baseDir}/scripts/baidupan.sh list / --limit 50         # 限制数量
{baseDir}/scripts/baidupan.sh list / --order time       # 按时间排序
{baseDir}/scripts/baidupan.sh list / --desc             # 降序
```

### 搜索文件
```bash
{baseDir}/scripts/baidupan.sh search "文件名"
{baseDir}/scripts/baidupan.sh search "pdf" --dir /文档
```

### 文件管理
```bash
{baseDir}/scripts/baidupan.sh mkdir /新文件夹                          # 创建目录
{baseDir}/scripts/baidupan.sh copy /源路径 /目标目录                   # 复制
{baseDir}/scripts/baidupan.sh move /源路径 /目标目录                   # 移动
{baseDir}/scripts/baidupan.sh rename /文件路径 新名称                  # 重命名
{baseDir}/scripts/baidupan.sh delete /文件路径                         # 删除
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

### 获取文件信息
```bash
{baseDir}/scripts/baidupan.sh meta /文件路径             # 文件详情
{baseDir}/scripts/baidupan.sh images                     # 图片列表
{baseDir}/scripts/baidupan.sh docs                       # 文档列表
```

### 刷新 Token
```bash
{baseDir}/scripts/baidupan.sh refresh                    # 刷新 access_token
```

## API 说明

| 功能 | 端点 |
|------|------|
| 用户信息 | GET /rest/2.0/xpan/nas?method=uinfo |
| 网盘容量 | GET /api/quota |
| 文件列表 | GET /rest/2.0/xpan/file?method=list |
| 搜索文件 | GET /rest/2.0/xpan/file?method=search |
| 图片列表 | GET /rest/2.0/xpan/file?method=imagelist |
| 文档列表 | GET /rest/2.0/xpan/file?method=doclist |
| 文件信息 | GET /rest/2.0/xpan/multimedia?method=filemetas |
| 递归列表 | GET /rest/2.0/xpan/multimedia?method=listall |
| 文件管理 | POST /rest/2.0/xpan/file?method=filemanager |
| 预上传 | POST /rest/2.0/xpan/file?method=precreate |
| 分片上传 | POST /rest/2.0/pcs/superfile2?method=upload |
| 创建文件 | POST /rest/2.0/xpan/file?method=create |

## 注意事项

- Access Token 有效期 30 天，过期需刷新
- Refresh Token 只能使用一次，刷新后会返回新的
- 路径需要 URL 编码（脚本会自动处理）
- 文件操作前请确认路径正确，删除不可恢复
- 上传功能可能需要STOKEN才能正常工作，仅BDUSS或访问令牌可能不足以完成上传操作
- BaiduPCS-Go 提供了更稳定和全面的百度网盘访问能力
