#!/usr/bin/env bash
# VM 综合跑分脚本
# 依赖：sysbench, fio, speedtest-cli, python3
# 日志保存在：~/logs/vm_benchmark_YYYYMMDD_HHMMSS.txt

set -e

LOG_DIR="$HOME/logs"
mkdir -p "$LOG_DIR"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$LOG_DIR/vm_benchmark_${TIMESTAMP}.txt"

run_section() {
  local title="$1"
  shift
  echo "==== ${title} ====" | tee -a "$LOG_FILE"
  echo "命令：$*"           | tee -a "$LOG_FILE"
  echo "------------------------" | tee -a "$LOG_FILE"
  "$@" 2>&1 | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
}

echo "==== VM 跑分日志 ====" | tee "$LOG_FILE"
echo "生成时间: $(date -R)"  | tee -a "$LOG_FILE"
echo                         | tee -a "$LOG_FILE"

# CPU
run_section "CPU 测试（sysbench 单线程）" \
  sysbench cpu --cpu-max-prime=20000 run

# 内存
run_section "内存带宽测试（sysbench memory 1G / 1K block）" \
  sysbench memory --memory-block-size=1K --memory-total-size=1G run

# 磁盘顺序写
run_section "磁盘顺序写（fio 256MB, bs=1M）" \
  fio --name=seqwrite --rw=write --size=256m --ioengine=libaio --bs=1M --direct=1

# 磁盘随机读
run_section "磁盘随机读（fio 256MB, bs=4K）" \
  fio --name=randread --rw=randread --size=256m --ioengine=libaio --bs=4K --direct=1

# 网络测速（自动选择最近服务器）
run_section "网络测速（speedtest-cli）" \
  speedtest-cli --secure --simple

# Python 10^8 加法循环
echo "==== Python 10^8 加法循环 ====" | tee -a "$LOG_FILE"
python3 - << 'EOF' 2>&1 | tee -a "$LOG_FILE"
import time
start = time.time()
x = 0
for i in range(10**8):
    x += i
print("Time for 10^8 additions:", time.time() - start, "seconds")
EOF
echo | tee -a "$LOG_FILE"

echo "✅ 跑分完成，日志：$LOG_FILE"
echo
echo "如需下载到本地桌面，可在本地终端执行（示例）："
echo "scp your_user@your_vm_ip:${LOG_FILE} ~/Desktop/"
echo "下载后如需清理远端日志：ssh your_user@your_vm_ip 'rm \"$LOG_FILE\"'"
