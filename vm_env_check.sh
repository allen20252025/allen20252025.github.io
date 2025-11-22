#!/usr/bin/env bash
# VM Ubuntu 24.04 环境检测脚本
# 检查并安装：sysbench, fio, speedtest-cli, python3

set -e

echo "=== [1/3] 检查包管理器（apt） ==="
if ! command -v apt-get >/dev/null 2>&1; then
  echo "未检测到 apt-get，此脚本仅适用于 Debian/Ubuntu 系 Linux。"
  exit 1
fi

NEED_UPDATE=0

install_if_missing() {
  local cmd="$1"
  local pkg="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[OK] $cmd 已安装"
  else
    echo "[!] 未检测到 $cmd，将安装软件包：$pkg"
    if [ "$NEED_UPDATE" -eq 0 ]; then
      echo "执行：sudo apt-get update ..."
      sudo apt-get update
      NEED_UPDATE=1
    fi
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
  fi
}

echo "=== [2/3] 检查并安装工具 ==="
install_if_missing sysbench sysbench
install_if_missing fio fio
install_if_missing speedtest-cli speedtest-cli
install_if_missing python3 python3
install_if_missing pip3 python3-pip || true

echo "=== [3/3] speedtest-cli（Python 版本）兜底安装 ==="
if ! command -v speedtest-cli >/dev/null 2>&1; then
  if command -v pip3 >/dev/null 2>&1; then
    echo "通过 pip3 安装 speedtest-cli ..."
    pip3 install --user speedtest-cli
  else
    echo "警告：未安装 pip3，且 apt 中的 speedtest-cli 安装失败。"
  fi
fi

echo
echo "✅ 环境检查完成，可执行跑分脚本。"
