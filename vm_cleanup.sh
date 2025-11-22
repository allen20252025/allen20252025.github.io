#!/usr/bin/env bash
# VM 日常安全清理脚本（非常保守）
# 清理范围：apt 缓存、当前用户缓存、/tmp 旧文件

set -e

LOG_DIR="$HOME/logs"
mkdir -p "$LOG_DIR"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$LOG_DIR/vm_cleanup_${TIMESTAMP}.txt"

{
  echo "==== VM 日常清理日志 ===="
  echo "时间: $(date -R)"
  echo

  echo "## 1. 清理 apt 缓存 (sudo apt-get clean)"
  sudo apt-get clean
  echo "完成。"
  echo

  echo "## 2. 清理当前用户缓存目录 ~/.cache/*"
  if [ -d "$HOME/.cache" ]; then
    rm -rf "$HOME/.cache"/*
    echo "~/.cache 已清空。"
  else
    echo "未找到 ~/.cache 目录。"
  fi
  echo

  echo "## 3. 清理 /tmp 中 7 天前的文件（不使用 sudo，只清理当前用户可写部分）"
  find /tmp -type f -mtime +7 -user "$USER" -print -delete 2>/dev/null || true
  echo "旧临时文件清理完成。"
  echo

  echo "## 4. 当前磁盘占用情况"
  df -hT
  echo
} > "$LOG_FILE"

echo "✅ 清理完成，详情日志：$LOG_FILE"
