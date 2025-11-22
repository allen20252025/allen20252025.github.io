cat << 'EOF' > check_env.sh
#!/usr/bin/env bash
# macOS 环境检测：sysbench, fio, speedtest-cli, python3

# 修正 CRLF 换行符（避免复制导致的隐藏错误）
sed -i '' 's/\r$//' "$0" 2>/dev/null

# 颜色输出
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
NC="\033[0m"

set -e

echo "=== [1/3] 检查 Homebrew ==="
if ! command -v brew >/dev/null 2>&1; then
  echo -e "${RED}❌ 未检测到 Homebrew${NC}"
  echo "请先安装 Homebrew：https://brew.sh"
  exit 1
else
  echo -e "${GREEN}[OK] Homebrew 已安装${NC}"
fi

install_if_missing() {
  local cmd="$1"
  local pkg="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo -e "${GREEN}[OK] $cmd 已安装${NC}"
  else
    echo -e "${YELLOW}[!] 未检测到 $cmd，将安装：$pkg${NC}"
    brew install "$pkg"
  fi
}

echo "=== [2/3] 检查并安装工具 ==="
install_if_missing sysbench sysbench
install_if_missing fio fio
install_if_missing speedtest-cli speedtest-cli

echo "=== [3/3] 检查 Python3 ==="
if command -v python3 >/dev/null 2>&1; then
  echo -e "${GREEN}[OK] python3 已安装：$(python3 --version)${NC}"
else
  echo -e "${YELLOW}[!] 未检测到 python3，正在安装 ...${NC}"
  brew install python
fi

echo
echo -e "${GREEN}🎉 macOS 环境检查完成，可执行跑分脚本。${NC}"
EOF

# 授权并运行
chmod +x check_env.sh
bash check_env.sh
