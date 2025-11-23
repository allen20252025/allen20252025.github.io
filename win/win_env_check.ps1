<# 
Windows 11 环境检测脚本
- 检查：Python、pip、speedtest-cli（Python版）
#>

Write-Host "=== [1/3] 检查 PowerShell 版本 ==="
$psv = $PSVersionTable.PSVersion
Write-Host "PowerShell Version:" $psv

Write-Host "`n=== [2/3] 检查 Python / pip ==="
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command python3 -ErrorAction SilentlyContinue
}

if ($python) {
    Write-Host "[OK] Python 已安装：" $python.Source
} else {
    Write-Warning "未检测到 Python，尝试使用 winget 安装 Python 3（需要 Win11 + 管理员权限）"
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        winget install --id Python.Python.3 -e --source winget
    } else {
        Write-Warning "未检测到 winget，请手动安装 Python：https://www.python.org/downloads/"
    }
}

# 重新检测 python
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command python3 -ErrorAction SilentlyContinue
}

if ($python) {
    Write-Host "[OK] Python 可用：" $python.Source
} else {
    Write-Warning "Python 仍不可用，后续 speedtest-cli 安装会失败。"
}

Write-Host "`n=== [3/3] 检查 speedtest-cli (Python) ==="
if ($python) {
    $speedtest = & $python.Source -m pip show speedtest-cli 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] speedtest-cli 已安装 (pip)。"
    } else {
        Write-Host "通过 pip 安装 speedtest-cli ..."
        & $python.Source -m pip install --user speedtest-cli
    }
} else {
    Write-Warning "由于 Python 不可用，无法安装 speedtest-cli。"
}

Write-Host "`n✅ Windows 环境检查完成。"
