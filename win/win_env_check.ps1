<#
Windows 11 环境检测脚本（优化版）
- 检查：PowerShell 版本、Python / pip、speedtest-cli（Python 版）
- 适合：在 Windows Terminal / PowerShell 里执行：  .\Check-WinEnv.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

Write-Host "=== Windows 11 环境检测脚本 ===`n" -ForegroundColor Cyan

#---------------------------
# 工具函数
#---------------------------

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

function Ensure-SpeedtestCli {
    param(
        [Parameter(Mandatory = $true)]
        [string] $PythonExe
    )

    Write-Host "`n=== [3/3] 检查 speedtest-cli (Python) ===" -ForegroundColor Yellow

    # 检查是否已安装
    & $PythonExe -m pip show speedtest-cli 1>$null 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] speedtest-cli 已安装 (pip)。" -ForegroundColor Green
        return
    }

    Write-Host "通过 pip 安装 speedtest-cli ..." -ForegroundColor Yellow
    try {
        & $PythonExe -m pip install --user speedtest-cli
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] speedtest-cli 安装完成。" -ForegroundColor Green
        } else {
            Write-Warning "pip 安装 speedtest-cli 失败（退出码：$LASTEXITCODE）。"
        }
    }
    catch {
        Write-Warning "安装 speedtest-cli 时出现异常：$($_.Exception.Message)"
    }
}

#---------------------------
# [1/3] 检查 PowerShell 版本
#---------------------------

Write-Host "=== [1/3] 检查 PowerShell 版本 ===" -ForegroundColor Yellow
$psv = $PSVersionTable.PSVersion
Write-Host "PowerShell Version: $psv"

#---------------------------
# [2/3] 检查 Python / pip
#---------------------------

Write-Host "`n=== [2/3] 检查 Python / pip ===" -ForegroundColor Yellow

$pythonPath = Get-PythonPath

if ($pythonPath) {
    Write-Host "[OK] 已检测到 Python：" $pythonPath -ForegroundColor Green
} else {
    Write-Warning "未检测到 Python，尝试使用 winget 安装 Python 3（需要 Win11 + 管理员权限）。"

    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        try {
            winget install --id Python.Python.3 -e --source winget
        }
        catch {
            Write-Warning "winget 安装 Python 失败：$($_.Exception.Message)"
        }
    } else {
        Write-Warning "未检测到 winget，请手动安装 Python：https://www.python.org/downloads/"
    }

    # 安装后再检测一次
    $pythonPath = Get-PythonPath
}

if ($pythonPath) {
    Write-Host "[OK] Python 可用：" $pythonPath -ForegroundColor Green
} else {
    Write-Warning "Python 仍不可用，后续 speedtest-cli 安装会跳过。"
}

#---------------------------
# [3/3] speedtest-cli
#---------------------------

if ($pythonPath) {
    Ensure-SpeedtestCli -PythonExe $pythonPath
} else {
    Write-Warning "由于 Python 不可用，跳过 speedtest-cli 检查。"
}

#---------------------------
# 结束语
#---------------------------

Write-Host "`n✅ Windows 环境检查完成。" -ForegroundColor Green
