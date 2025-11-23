<# 
Windows 11 跑分脚本
依赖：Python + speedtest-cli（由 win_env_check.ps1 安装）
日志路径：桌面\win_benchmark_YYYYMMDD_HHMMSS.txt
#>

$Desktop   = [Environment]::GetFolderPath('Desktop')
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile   = Join-Path $Desktop "win_benchmark_$Timestamp.txt"

function Write-Section {
    param(
        [string]$Title,
        [string]$CommandDesc
    )
    "==== $Title ====" | Out-File $LogFile -Append
    if ($CommandDesc) {
        "说明：$CommandDesc" | Out-File $LogFile -Append
    }
    "------------------------" | Out-File $LogFile -Append
}

"==== Windows 跑分日志 ====" | Out-File $LogFile -Encoding UTF8
"生成时间: $(Get-Date -Format R)`n" | Out-File $LogFile -Append

# CPU 测试
Write-Section "CPU 测试（10^8 次平方根运算）" "PowerShell 循环 + [math]::Sqrt"
$cpuTime = Measure-Command {
    for ($i = 0; $i -lt 100000000; $i++) {
        [math]::Sqrt($i) | Out-Null
    }
}
"耗时: {0} 秒" -f $cpuTime.TotalSeconds | Out-File $LogFile -Append
"`n" | Out-File $LogFile -Append

# 内存测试
Write-Section "内存测试（分配并写入 512MB 数组）" "byte[512MB]"
$memTime = Measure-Command {
    $size = 512MB
    $bytes = New-Object byte[] $size
    for ($i = 0; $i -lt $bytes.Length; $i+=4096) {
        $bytes[$i] = 1
    }
}
"耗时: {0} 秒" -f $memTime.TotalSeconds | Out-File $LogFile -Append
"`n" | Out-File $LogFile -Append

# 磁盘测试（winsat disk）
Write-Section "磁盘测试（winsat disk）" "winsat disk -drive c"
try {
    $winsatOutput = winsat disk -drive c
    $winsatOutput | Out-File $LogFile -Append
} catch {
    "winsat disk 执行失败：$($_.Exception.Message)" | Out-File $LogFile -Append
}
"`n" | Out-File $LogFile -Append

# 网络测速（speedtest-cli）
Write-Section "网络测速（speedtest-cli）" "python -m speedtest --simple"
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command python3 -ErrorAction SilentlyContinue
}
if ($python) {
    try {
        & $python.Source -m speedtest --simple 2>&1 | Out-File $LogFile -Append
    } catch {
        "speedtest-cli 执行失败：$($_.Exception.Message)" | Out-File $LogFile -Append
    }
} else {
    "未检测到 Python，无法执行 speedtest-cli。" | Out-File $LogFile -Append
}
"`n" | Out-File $LogFile -Append

# Python 10^8 加法循环（保持和 Linux/mac 一致）
Write-Section "Python 10^8 加法循环" "python 等价代码"
if ($python) {
    & $python.Source - << 'EOF' 2>&1 | Out-File $LogFile -Append
import time
start = time.time()
x = 0
for i in range(10**8):
    x += i
print("Time for 10^8 additions:", time.time() - start, "seconds")
EOF
} else {
    "Python 不可用，跳过本测试。" | Out-File $LogFile -Append
}

"`n✅ 跑分完成，日志：$LogFile" | Out-File $LogFile -Append
Write-Host "✅ 跑分完成，日志：$LogFile"
