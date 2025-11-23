<#
Windows 11 日常安全清理（保守版）
- 清理当前用户 TEMP
- 仅在管理员权限下：清理系统 TEMP
- 清空回收站
日志路径：桌面\win_cleanup_YYYYMMDD_HHMMSS.txt

用法：
1）直接在 PowerShell 里一次性粘贴整段代码回车执行
2）或保存为 win_cleanup.ps1，用 .\win_cleanup.ps1 运行
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

#--------------------------------------------------
# 日志文件准备
#--------------------------------------------------
$Desktop   = [Environment]::GetFolderPath('Desktop')
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile   = Join-Path $Desktop "win_cleanup_$Timestamp.txt"

# 简单日志函数（支持管道）
if (Get-Command Write-Log -CommandType Function -ErrorAction SilentlyContinue) {
    Remove-Item Function:\Write-Log
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

# 是否为管理员
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
            [Security.Principal.WindowsIdentity]::GetCurrent()
           ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

#--------------------------------------------------
# 日志头部
#--------------------------------------------------
"==== Windows 日常清理日志 ====" | Out-File $LogFile -Encoding UTF8
"时间: $(Get-Date -Format R)`n"   | Write-Log

#--------------------------------------------------
# 1. 当前用户 TEMP
#--------------------------------------------------
"## 1. 清理当前用户 TEMP ($env:TEMP)" | Write-Log
try {
    if (Test-Path $env:TEMP) {
        Get-ChildItem $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        "已清理 $env:TEMP" | Write-Log
    } else {
        "未找到目录：$env:TEMP，跳过。" | Write-Log
    }
}
catch {
    ("清理用户 TEMP 失败：{0}" -f $_.Exception.Message) | Write-Log
}
"`n" | Write-Log

#--------------------------------------------------
# 2. 系统 TEMP（仅管理员执行）
#--------------------------------------------------
"## 2. 清理系统 TEMP (C:\Windows\Temp)" | Write-Log

if ($IsAdmin) {
    try {
        if (Test-Path "C:\Windows\Temp") {
            Get-ChildItem "C:\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            "已尝试清理 C:\Windows\Temp（部分被占用文件可能被跳过）。" | Write-Log
        } else {
            "未找到目录：C:\Windows\Temp，跳过。" | Write-Log
        }
    }
    catch {
        ("清理系统 TEMP 失败：{0}" -f $_.Exception.Message) | Write-Log
    }
} else {
    "当前非管理员权限，出于安全已跳过系统 TEMP 清理。" | Write-Log
}
"`n" | Write-Log

#--------------------------------------------------
# 3. 清空回收站
#--------------------------------------------------
"## 3. 清空回收站" | Write-Log
try {
    if (Get-Command Clear-RecycleBin -ErrorAction SilentlyContinue) {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        "回收站已清空。" | Write-Log
    } else {
        "当前环境不支持 Clear-RecycleBin 命令，跳过。" | Write-Log
    }
}
catch {
    ("清空回收站失败：{0}" -f $_.Exception.Message) | Write-Log
}
"`n" | Write-Log

#--------------------------------------------------
# 4. 当前磁盘使用情况
#--------------------------------------------------
"## 4. 当前磁盘使用情况" | Write-Log
try {
    Get-CimInstance Win32_LogicalDisk |
        Select-Object DeviceID, Size, FreeSpace |
        Format-Table -AutoSize |
        Out-String | Write-Log
}
catch {
    ("获取磁盘信息失败：{0}" -f $_.Exception.Message) | Write-Log
}
"`n" | Write-Log

#--------------------------------------------------
# 结束
#--------------------------------------------------
"✅ 清理完成，详情日志：$LogFile" | Write-Log
Write-Host "✅ 清理完成，详情日志：$LogFile" -ForegroundColor Cyan
