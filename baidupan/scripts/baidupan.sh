#!/usr/bin/env bash
# 百度网盘 CLI 封装
# 用法: baidupan.sh <command> [args...]

set -euo pipefail

# 配置
API_BASE="https://pan.baidu.com"
OAUTH_BASE="https://openapi.baidu.com"
USER_AGENT="pan.baidu.com"

# 检查 token
check_token() {
  if [[ -z "${BAIDU_PAN_ACCESS_TOKEN:-}" ]]; then
    echo "错误: 请设置 BAIDU_PAN_ACCESS_TOKEN 环境变量" >&2
    exit 1
  fi
}

# URL 编码
urlencode() {
  python3 -c "import urllib.parse; print(urllib.parse.quote('$1', safe=''))"
}

# API 请求 (GET)
api_get() {
  local endpoint="$1"
  shift
  local url="${API_BASE}${endpoint}"
  
  # 添加 access_token
  if [[ "$url" == *"?"* ]]; then
    url="${url}&access_token=${BAIDU_PAN_ACCESS_TOKEN}"
  else
    url="${url}?access_token=${BAIDU_PAN_ACCESS_TOKEN}"
  fi
  
  curl -sS -X GET "$url" -H "User-Agent: ${USER_AGENT}" "$@"
}

# API 请求 (POST)
api_post() {
  local endpoint="$1"
  shift
  local url="${API_BASE}${endpoint}"
  
  if [[ "$url" == *"?"* ]]; then
    url="${url}&access_token=${BAIDU_PAN_ACCESS_TOKEN}"
  else
    url="${url}?access_token=${BAIDU_PAN_ACCESS_TOKEN}"
  fi
  
  curl -sS -X POST "$url" -H "User-Agent: ${USER_AGENT}" "$@"
}

# 用户信息
cmd_user() {
  check_token
  api_get "/rest/2.0/xpan/nas?method=uinfo" | jq
}

# 网盘容量
cmd_quota() {
  check_token
  api_get "/api/quota?checkexpire=1&checkfree=1" | jq '{
    total: (.total / 1073741824 | floor | tostring + " GB"),
    used: (.used / 1073741824 * 100 | floor / 100 | tostring + " GB"),
    free: ((.total - .used) / 1073741824 * 100 | floor / 100 | tostring + " GB"),
    expire: .expire
  }'
}

# 文件列表
cmd_list() {
  check_token
  local dir="${1:-/}"
  shift || true
  
  local order="name"
  local desc=0
  local limit=100
  local start=0
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --order) order="$2"; shift 2 ;;
      --desc) desc=1; shift ;;
      --limit) limit="$2"; shift 2 ;;
      --start) start="$2"; shift 2 ;;
      *) shift ;;
    esac
  done
  
  local encoded_dir
  encoded_dir=$(urlencode "$dir")
  
  api_get "/rest/2.0/xpan/file?method=list&dir=${encoded_dir}&order=${order}&desc=${desc}&start=${start}&limit=${limit}&web=1" | jq '{
    errno: .errno,
    count: (.list | length),
    files: [.list[] | {
      name: .server_filename,
      path: .path,
      size: (if .isdir == 1 then "-" else (.size | tostring + " bytes") end),
      isdir: (.isdir == 1),
      mtime: (.server_mtime | strftime("%Y-%m-%d %H:%M")),
      fs_id: .fs_id
    }]
  }'
}

# 搜索文件
cmd_search() {
  check_token
  local key="$1"
  shift || true
  
  local dir="/"
  local limit=100
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dir) dir="$2"; shift 2 ;;
      --limit) limit="$2"; shift 2 ;;
      *) shift ;;
    esac
  done
  
  local encoded_key
  encoded_key=$(urlencode "$key")
  local encoded_dir
  encoded_dir=$(urlencode "$dir")
  
  api_get "/rest/2.0/xpan/file?method=search&key=${encoded_key}&dir=${encoded_dir}&num=${limit}&web=1" | jq '{
    errno: .errno,
    count: (.list | length),
    files: [.list[] | {
      name: .server_filename,
      path: .path,
      size: (if .isdir == 1 then "-" else (.size | tostring + " bytes") end),
      isdir: (.isdir == 1),
      mtime: (.server_mtime | strftime("%Y-%m-%d %H:%M"))
    }]
  }'
}

# 图片列表
cmd_images() {
  check_token
  local limit="${1:-100}"
  
  api_get "/rest/2.0/xpan/file?method=imagelist&num=${limit}&web=1" | jq '{
    errno: .errno,
    count: (.info | length),
    images: [.info[] | {
      name: .server_filename,
      path: .path,
      size: (.size | tostring + " bytes"),
      mtime: (.server_mtime | strftime("%Y-%m-%d %H:%M")),
      thumbs: .thumbs
    }]
  }'
}

# 文档列表
cmd_docs() {
  check_token
  local limit="${1:-100}"
  
  api_get "/rest/2.0/xpan/file?method=doclist&num=${limit}&web=1" | jq '{
    errno: .errno,
    count: (.info | length),
    docs: [.info[] | {
      name: .server_filename,
      path: .path,
      size: (.size | tostring + " bytes"),
      mtime: (.server_mtime | strftime("%Y-%m-%d %H:%M"))
    }]
  }'
}

# 文件信息
cmd_meta() {
  check_token
  local path="$1"
  
  # 先搜索获取 fs_id
  local encoded_path
  encoded_path=$(urlencode "$path")
  
  api_get "/rest/2.0/xpan/multimedia?method=filemetas&fsids=[${1}]&dlink=1" | jq
}

# 创建目录
cmd_mkdir() {
  check_token
  local path="$1"
  
  api_post "/rest/2.0/xpan/file?method=create" \
    -d "path=${path}&size=0&isdir=1&rtype=0" | jq
}

# 文件操作（复制/移动/删除/重命名）
file_manager() {
  check_token
  local opera="$1"
  shift
  
  local filelist="$1"
  
  api_post "/rest/2.0/xpan/file?method=filemanager&opera=${opera}" \
    -d "async=0&filelist=${filelist}" | jq
}

# 复制
cmd_copy() {
  check_token
  local src="$1"
  local dest="$2"
  local newname
  newname=$(basename "$src")
  
  local filelist="[{\"path\":\"${src}\",\"dest\":\"${dest}\",\"newname\":\"${newname}\",\"ondup\":\"fail\"}]"
  file_manager "copy" "$filelist"
}

# 移动
cmd_move() {
  check_token
  local src="$1"
  local dest="$2"
  local newname
  newname=$(basename "$src")
  
  local filelist="[{\"path\":\"${src}\",\"dest\":\"${dest}\",\"newname\":\"${newname}\",\"ondup\":\"fail\"}]"
  file_manager "move" "$filelist"
}

# 删除
cmd_delete() {
  check_token
  local path="$1"
  
  local filelist="[\"${path}\"]"
  file_manager "delete" "$filelist"
}

# 重命名
cmd_rename() {
  check_token
  local path="$1"
  local newname="$2"
  
  local filelist="[{\"path\":\"${path}\",\"newname\":\"${newname}\"}]"
  file_manager "rename" "$filelist"
}

# 上传文件
cmd_upload() {
  if ! command -v BaiduPCS-Go &> /dev/null; then
    echo "错误: BaiduPCS-Go 未安装" >&2
    echo "请先运行: {baseDir}/install_baidupcs_go.sh" >&2
    exit 1
  fi
  
  local local_file="$1"
  local remote_dir="$2"
  
  if [[ ! -f "$local_file" ]]; then
    echo "错误: 本地文件不存在: $local_file" >&2
    exit 1
  fi
  
  # 使用 BaiduPCS-Go 上传文件
  BaiduPCS-Go upload "$local_file" "$remote_dir"
}

# 刷新 token
cmd_refresh() {
  if [[ -z "${BAIDU_PAN_REFRESH_TOKEN:-}" ]]; then
    echo "错误: 请设置 BAIDU_PAN_REFRESH_TOKEN 环境变量" >&2
    exit 1
  fi
  if [[ -z "${BAIDU_PAN_APP_KEY:-}" ]]; then
    echo "错误: 请设置 BAIDU_PAN_APP_KEY 环境变量" >&2
    exit 1
  fi
  if [[ -z "${BAIDU_PAN_SECRET_KEY:-}" ]]; then
    echo "错误: 请设置 BAIDU_PAN_SECRET_KEY 环境变量" >&2
    exit 1
  fi
  
  curl -sS -X GET "${OAUTH_BASE}/oauth/2.0/token?grant_type=refresh_token&refresh_token=${BAIDU_PAN_REFRESH_TOKEN}&client_id=${BAIDU_PAN_APP_KEY}&client_secret=${BAIDU_PAN_SECRET_KEY}" \
    -H "User-Agent: ${USER_AGENT}" | jq '{
    access_token: .access_token,
    refresh_token: .refresh_token,
    expires_in: .expires_in,
    expires_in_days: (.expires_in / 86400 | floor)
  }'
}

# 帮助
cmd_help() {
  cat <<EOF
百度网盘 CLI

用法: baidupan.sh <command> [args...]

命令:
  user                      用户信息
  quota                     网盘容量
  list <dir> [options]      文件列表
    --order <name|time|size>  排序字段
    --desc                    降序
    --limit <n>               数量限制
    --start <n>               起始位置
  search <key> [options]    搜索文件
    --dir <path>              搜索目录
    --limit <n>               数量限制
  images [limit]            图片列表
  docs [limit]              文档列表
  meta <fs_id>              文件详情
  mkdir <path>              创建目录
  copy <src> <dest>         复制文件
  move <src> <dest>         移动文件
  rename <path> <newname>   重命名
  delete <path>             删除文件
  upload <local_file> <remote_path>  上传文件（需安装BaiduPCS-Go）
  refresh                   刷新 token
  help                      显示帮助

环境变量:
  BAIDU_PAN_ACCESS_TOKEN    访问令牌（必需）
  BAIDU_PAN_REFRESH_TOKEN   刷新令牌（刷新 token 时需要）
  BAIDU_PAN_APP_KEY         应用 AppKey（刷新 token 时需要）
  BAIDU_PAN_SECRET_KEY      应用 SecretKey（刷新 token 时需要）
EOF
}

# 主入口
main() {
  local cmd="${1:-help}"
  shift || true
  
  case "$cmd" in
    user) cmd_user "$@" ;;
    quota) cmd_quota "$@" ;;
    list) cmd_list "$@" ;;
    search) cmd_search "$@" ;;
    images) cmd_images "$@" ;;
    docs) cmd_docs "$@" ;;
    meta) cmd_meta "$@" ;;
    mkdir) cmd_mkdir "$@" ;;
    copy) cmd_copy "$@" ;;
    move) cmd_move "$@" ;;
    rename) cmd_rename "$@" ;;
    delete) cmd_delete "$@" ;;
    upload) cmd_upload "$@" ;;
    refresh) cmd_refresh "$@" ;;
    help|--help|-h) cmd_help ;;
    *) echo "未知命令: $cmd"; cmd_help; exit 1 ;;
  esac
}

main "$@"