#!/usr/bin/env bash
# VM 系统信息采集脚本
# 日志保存在：~/logs/vm_sysinfo_YYYYMMDD_HHMMSS.txt

set -e

LOG_DIR="$HOME/logs"
mkdir -p "$LOG_DIR"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$LOG_DIR/vm_sysinfo_${TIMESTAMP}.txt"

{
  echo "==== VM 系统信息日志 ===="
  echo "生成时间: $(date -R)"
  echo

  echo "## 基本内核与发行版信息"
  uname -a
  echo
  if [ -f /etc/os-release ]; then
    cat /etc/os-release
  fi
  echo

  echo "## CPU 信息"
  if command -v lscpu >/dev/null 2>&1; then
    lscpu
  else
    cat /proc/cpuinfo
  fi
  echo

  echo "## 内存信息"
  free -h
  echo

  echo "## 磁盘与分区"
  lsblk -o NAME,FSTYPE,SIZE,TYPE,MOUNTPOINT
  echo
  df -hT
  echo

  echo "## 网络配置"
  ip address
  echo
  ip route
  echo

  echo "## 挂载磁盘详细信息（如有）"
  ls -l /dev/disk/by-id 2>/dev/null || echo "(无 /dev/disk/by-id 信息)"
  echo

  echo "## 进程与负载快照"
  uptime
  echo
  ps aux --sort=-%mem | head -n 15
  echo

  echo "## 安全相关（selinux/apparmor 状态等）"
  if command -v sestatus >/dev/null 2>&1; then
    sestatus
  else
    echo "sestatus 未安装（通常在 Ubuntu 上也不启用 SELinux）"
  fi
  echo
} > "$LOG_FILE"

echo "✅ 系统信息已写入：$LOG_FILE"
echo
echo "如需下载到本地桌面，可在本地终端执行（示例）："
echo "scp your_user@your_vm_ip:${LOG_FILE} ~/Desktop/"
echo "（下载成功后可手动 ssh 进 VM 执行：rm \"$LOG_FILE\" 删除远端日志）"
