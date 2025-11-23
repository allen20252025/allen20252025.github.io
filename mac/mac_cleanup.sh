#!/usr/bin/env bash
# macOS 日常安全清理（保守版）
# 清理：用户缓存、Trash、Homebrew 缓存

set -e

DESKTOP="$HOME/Desktop"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$DESKTOP/mac_cleanup_${TIMESTAMP}.txt"

{
  echo "==== macOS 日常清理日志 ===="
  echo "时间: $(date -R)"
  echo

  echo "## 1. 清理用户缓存 ~/Library/Caches/*"
  if [ -d "$HOME/Library/Caches" ]; then
    rm -rf "$HOME/Library/Caches"/*
    echo "已清空 ~/Library/Caches。"
  else
    echo "未找到 ~/Library/Caches。"
  fi
  echo

  echo "## 2. 清空废纸篓 ~/.Trash"
  if [ -d "$HOME/.Trash" ]; then
    rm -rf "$HOME/.Trash"/*
    echo "废纸篓已清空。"
  else
    echo "未找到 ~/.Trash。"
  fi
  echo

  echo "## 3. 清理 Homebrew 缓存（如有）"
  if command -v brew >/dev/null 2>&1; then
    brew cleanup -s
    echo "brew cleanup 完成。"
  else
    echo "未安装 Homebrew，跳过。"
  fi
  echo

  echo "## 4. 当前磁盘占用"
  df -h
  echo
} > "$LOG_FILE"

echo "✅ 清理完成，详情日志：$LOG_FILE"
