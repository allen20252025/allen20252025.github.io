#!/usr/bin/env bash
# macOS 综合跑分脚本
# 日志保存在桌面：~/Desktop/mac_benchmark_YYYYMMDD_HHMMSS.txt

set -e

DESKTOP="$HOME/Desktop"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$DESKTOP/mac_benchmark_${TIMESTAMP}.txt"

run_section() {
  local title="$1"
  shift
  echo "==== ${title} ====" | tee -a "$LOG_FILE"
  echo "命令：$*"           | tee -a "$LOG_FILE"
  echo "------------------------" | tee -a "$LOG_FILE"
  "$@" 2>&1 | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
}

echo "==== macOS 跑分日志 ====" | tee "$LOG_FILE"
echo "生成时间: $(date -R)"     | tee -a "$LOG_FILE"
echo                           | tee -a "$LOG_FILE"

# CPU
run_section "CPU 测试（sysbench 单线程）" \
  sysbench cpu --cpu-max-prime=20000 run

# 内存
run_section "内存带宽测试（1G / 1K block）" \
  sysbench memory --memory-block-size=1K --memory-total-size=1G run

# 磁盘顺序写
run_section "磁盘顺序写（fio 256MB, bs=1M）" \
  fio --name=seqwrite --rw=write --size=256m --ioengine=posixaio --bs=1M --direct=1

# 磁盘随机读
run_section "磁盘随机读（fio 256MB, bs=4K）" \
  fio --name=randread --rw=randread --size=256m --ioengine=posixaio --bs=4K --direct=1

# 🧹 FIO 测试文件清理（新增）
rm -f seqwrite.* randread.* >/dev/null 2>&1 || true

# 网络测速（⚠️ 服务器不可用则给提示，不终止脚本）
run_section "网络测速（speedtest-cli）" \
  bash -c 'speedtest-cli --secure --simple || echo "⚠️ speedtest 服务器不可用，已跳过测速"'

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
