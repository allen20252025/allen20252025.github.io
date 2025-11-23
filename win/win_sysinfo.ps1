<#
Windows 11 系统信息日志脚本（修正版）
- 日志路径：桌面\win_sysinfo_YYYYMMDD_HHMMSS.txt
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

#--------------------------------------------------
# 日志文件准备
#--------------------------------------------------
$Desktop   = [Environment]::GetFolderPath('Desktop')
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile   = Join-Path $Desktop "win_sysinfo_$Timestamp.txt"

# 如果之前已经存在同名函数，先移除（防止旧版本干扰）
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

# 头部
"==== Windows 系统信息日志 ===="      | Out-File $LogFile -Encoding UTF8
"生成时间: $(Get-Date -Format R)`n" | Out-File $LogFile -Append -Encoding UTF8

#--------------------------------------------------
# 基本 OS 信息
#--------------------------------------------------
"## 基本 OS 信息" | Write-Log
Get-ComputerInfo |
    Select-Object OsName, OsVersion, WindowsProductName, WindowsEditionId, CsName |
    Format-List | Out-String | Write-Log
"`n" | Write-Log

#--------------------------------------------------
# CPU 信息
#--------------------------------------------------
"## CPU 信息" | Write-Log
Get-CimInstance Win32_Processor |
    Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed |
    Format-List | Out-String | Write-Log
"`n" | Write-Log

#--------------------------------------------------
# 内存信息
#--------------------------------------------------
"## 内存信息" | Write-Log
Get-CimInstance Win32_PhysicalMemory |
    Select-Object Manufacturer, Speed, Capacity |
    Format-Table -AutoSize | Out-String | Write-Log
"`n" | Write-Log

#--------------------------------------------------
# 显卡信息
#--------------------------------------------------
"## 显卡信息" | Write-Log
Get-CimInstance Win32_VideoController |
    Select-Object Name, DriverVersion, AdapterRAM |
    Format-Table -AutoSize | Out-String | Write-Log
"`n" | Write-Log

#--------------------------------------------------
# 磁盘与分区信息
#--------------------------------------------------
"## 磁盘与分区信息" | Write-Log
Get-CimInstance Win32_LogicalDisk |
    Select-Object DeviceID, FileSystem, Size, FreeSpace |
    Format-Table -AutoSize | Out-String | Write-Log
"`n" | Write-Log

#--------------------------------------------------
# 网络接口信息
#--------------------------------------------------
"## 网络接口信息" | Write-Log
Get-NetIPAddress |
    Select-Object InterfaceAlias, IPAddress, PrefixLength, AddressFamily |
    Format-Table -AutoSize | Out-String | Write-Log
"`n" | Write-Log

#--------------------------------------------------
# 当前负载（CPU / 内存）快照
#--------------------------------------------------
"## 当前负载（CPU / 内存）快照" | Write-Log
Get-Counter '\Processor(_Total)\% Processor Time','\Memory\Available MBytes' |
    Format-List | Out-String | Write-Log
"`n" | Write-Log

"✅ 系统信息日志已生成：$LogFile" | Write-Log

# 控制台提示
Write-Host "✅ 系统信息日志已生成：" -NoNewline
Write-Host $LogFile -ForegroundColor Cyan
