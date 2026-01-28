---
name: baidupan
description: 百度网盘 API 操作：文件列表、搜索、上传、下载、管理（复制/移动/删除/重命名）、用户信息。
homepage: https://pan.baidu.com/union/doc
metadata: {"clawdbot":{"emoji":"☁️","requires":{"bins":["curl","jq"],"env":["BAIDU_PAN_ACCESS_TOKEN"]},"primaryEnv":"BAIDU_PAN_ACCESS_TOKEN"}}
---

# 百度网盘 (Baidu Pan)

通过百度网盘开放 API 管理云端文件。

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

## 快速开始

```bash
# 查看用户信息
{baseDir}/scripts/baidupan.sh user

# 查看网盘容量
{baseDir}/scripts/baidupan.sh quota

# 列出根目录文件
{baseDir}/scripts/baidupan.sh list /

# 搜索文件
{baseDir}/scripts/baidupan.sh search "关键词"
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
