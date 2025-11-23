<#
Windows 11 跑分脚本（优化版）
依赖：Python + speedtest-cli（由 win_env_check.ps1 安装）
日志路径：桌面\win_benchmark_YYYYMMDD_HHMMSS.txt
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

#--------------------------------------------------
# 日志文件准备
#--------------------------------------------------
$Desktop   = [Environment]::GetFolderPath('Desktop')
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile   = Join-Path $Desktop "win_benchmark_$Timestamp.txt"

# 如果之前已有同名函数，先移除，防止之前会话里的旧版本干扰
if (Get-Command Write-Log -CommandType Function -ErrorAction SilentlyContinue) {
    Remove-Item Function:\Write-Log
}
if (Get-Command Write-Section -CommandType Function -ErrorAction SilentlyContinue) {
    Remove-Item Function:\Write-Section
}
if (Get-Command Get-PythonPath -CommandType Function -ErrorAction SilentlyContinue) {
    Remove-Item Function:\Get-PythonPath
}

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string] $Text
    )

    process {
        $Text | Out-File $LogFile -Append -Encoding UTF8
    }
}

function Write-Section {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Title,

        [string] $CommandDesc
    )

    "==== $Title ====" | Write-Log
    if ($CommandDesc) {
        "说明：$CommandDesc" | Write-Log
    }
    "------------------------" | Write-Log
}

function Get-PythonPath {
    $candidates = @('python', 'python3', 'py')
    foreach ($name in $candidates) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) {
            return $cmd.Source
        }
    }
    return $null
}

#--------------------------------------------------
# 日志头部
#--------------------------------------------------
"==== Windows 跑分日志 ====" | Out-File $LogFile -Encoding UTF8
"生成时间: $(Get-Date -Format R)`n" | Write-Log

# 预先找一次 Python，后面多处复用
$pythonPath = Get-PythonPath

#--------------------------------------------------
# CPU 测试
#--------------------------------------------------
# 注意：10^8 次平方根运算会比较久，纯 CPU 压力测试
Write-Section "CPU 测试（10^8 次平方根运算）" "PowerShell 循环 + [math]::Sqrt"

$cpuTime = Measure-Command {
    for ($i = 0; $i -lt 100000000; $i++) {
        [math]::Sqrt($i) | Out-Null
    }
}

("耗时: {0:N3} 秒" -f $cpuTime.TotalSeconds) | Write-Log
"`n" | Write-Log

#--------------------------------------------------
# 内存测试
#--------------------------------------------------
Write-Section "内存测试（分配并写入 512MB 数组）" "New-Object byte[512MB]，每 4KB 写一次"

try {
    $sizeBytes = 512MB   # 512 * 1024 * 1024
    $bytes = New-Object byte[] $sizeBytes

    $memTime = Measure-Command {
        for ($i = 0; $i -lt $bytes.Length; $i += 4096) {
            $bytes[$i] = 1
        }
    }

    ("耗时: {0:N3} 秒" -f $memTime.TotalSeconds) | Write-Log
}
catch {
    ("内存测试失败：{0}" -f $_.Exception.Message) | Write-Log
}
"`n" | Write-Log

#--------------------------------------------------
# 磁盘测试（winsat disk）
#--------------------------------------------------
Write-Section "磁盘测试（winsat disk）" "winsat disk -drive c"

try {
    $winsatOutput = winsat disk -drive c 2>&1
    $winsatOutput | Write-Log
}
catch {
    ("winsat disk 执行失败：{0}" -f $_.Exception.Message) | Write-Log
}
"`n" | Write-Log

#--------------------------------------------------
# 网络测速（speedtest-cli）
#--------------------------------------------------
Write-Section "网络测速（speedtest-cli）" "python -m speedtest --simple"

if ($pythonPath) {
    try {
        & $pythonPath -m speedtest --simple 2>&1 | Write-Log
    }
    catch {
        ("speedtest-cli 执行失败：{0}" -f $_.Exception.Message) | Write-Log
    }
} else {
    "未检测到 Python，无法执行 speedtest-cli。" | Write-Log
}
"`n" | Write-Log

#--------------------------------------------------
# Python 10^8 加法循环
#--------------------------------------------------
Write-Section "Python 10^8 加法循环" "与 Linux/mac 脚本一致的 10^8 次加法"

if ($pythonPath) {
    $pyCode = @"
import time
start = time.time()
x = 0
for i in range(10**8):
    x += i
print("Time for 10^8 additions:", time.time() - start, "seconds")
"@

    try {
        $pyCode | & $pythonPath - 2>&1 | Write-Log
    }
    catch {
        ("Python 跑分脚本执行失败：{0}" -f $_.Exception.Message) | Write-Log
    }
} else {
    "Python 不可用，跳过本测试。" | Write-Log
}
"`n" | Write-Log

#--------------------------------------------------
# 结束
#--------------------------------------------------
"✅ 跑分完成，日志：$LogFile" | Write-Log
Write-Host "✅ 跑分完成，日志：$LogFile" -ForegroundColor Cyan
