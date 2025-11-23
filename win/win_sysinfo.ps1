<# 
Windows 11 系统信息日志脚本
日志路径：桌面\win_sysinfo_YYYYMMDD_HHMMSS.txt
#>

$Desktop = [Environment]::GetFolderPath('Desktop')
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = Join-Path $Desktop "win_sysinfo_$Timestamp.txt"

"==== Windows 系统信息日志 ====" | Out-File $LogFile -Encoding UTF8
"生成时间: $(Get-Date -Format R)`n" | Out-File $LogFile -Append

"## 基本 OS 信息" | Out-File $LogFile -Append
Get-ComputerInfo | Select-Object OsName, OsVersion, WindowsProductName, WindowsEditionId, CsName |
    Format-List | Out-String | Out-File $LogFile -Append
"`n" | Out-File $LogFile -Append

"## CPU 信息" | Out-File $LogFile -Append
Get-CimInstance Win32_Processor |
    Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed |
    Format-List | Out-String | Out-File $LogFile -Append
"`n" | Out-File $LogFile -Append

"## 内存信息" | Out-File $LogFile -Append
Get-CimInstance Win32_PhysicalMemory |
    Select-Object Manufacturer, Speed, Capacity |
    Format-Table -AutoSize | Out-String | Out-File $LogFile -Append
"`n" | Out-File $LogFile -Append

"## 显卡信息" | Out-File $LogFile -Append
Get-CimInstance Win32_VideoController |
    Select-Object Name, DriverVersion, AdapterRAM |
    Format-Table -AutoSize | Out-String | Out-File $LogFile -Append
"`n" | Out-File $LogFile -Append

"## 磁盘与分区信息" | Out-File $LogFile -Append
Get-CimInstance Win32_LogicalDisk |
    Select-Object DeviceID, FileSystem, Size, FreeSpace |
    Format-Table -AutoSize | Out-String | Out-File $LogFile -Append
"`n" | Out-File $LogFile -Append

"## 网络接口信息" | Out-File $LogFile -Append
Get-NetIPAddress |
    Select-Object InterfaceAlias, IPAddress, PrefixLength, AddressFamily |
    Format-Table -AutoSize | Out-String | Out-File $LogFile -Append
"`n" | Out-File $LogFile -Append

"## 当前负载（CPU / 内存）快照" | Out-File $LogFile -Append
Get-Counter '\Processor(_Total)\% Processor Time','\Memory\Available MBytes' |
    Format-List | Out-String | Out-File $LogFile -Append
"`n" | Out-File $LogFile -Append

"✅ 系统信息日志已生成：$LogFile" | Out-File $LogFile -Append

Write-Host "✅ 系统信息日志已生成：$LogFile"
