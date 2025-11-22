#!/usr/bin/env bash
# macOS 系统信息采集
# 日志保存在桌面：~/Desktop/mac_sysinfo_YYYYMMDD_HHMMSS.txt

set -e

DESKTOP="$HOME/Desktop"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$DESKTOP/mac_sysinfo_${TIMESTAMP}.txt"

{
  echo "==== macOS 系统信息日志 ===="
  echo "生成时间: $(date -R)"
  echo

  echo "## 系统版本信息"
  sw_vers
  echo

  echo "## 硬件信息（CPU / 内存 / 型号）"
  system_profiler SPHardwareDataType
  echo

  echo "## 存储信息（磁盘 / 分区）"
  system_profiler SPStorageDataType
  echo
  diskutil list
  echo

  echo "## 显示器信息"
  system_profiler SPDisplaysDataType
  echo

  echo "## 网络配置"
  ifconfig
  echo
  netstat -rn
  echo

  echo "## 当前负载与进程快照"
  uptime
  echo
  ps aux | head -n 20
  echo
} > "$LOG_FILE"

echo "✅ 系统信息日志已生成：$LOG_FILE"
