<# 
Windows 11 日常安全清理（保守版）
- 清理当前用户 TEMP
- 可选：清理系统 TEMP（需要管理员）
- 清空回收站
日志路径：桌面\win_cleanup_YYYYMMDD_HHMMSS.txt
#>

$Desktop   = [Environment]::GetFolderPath('Desktop')
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile   = Join-Path $Desktop "win_cleanup_$Timestamp.txt"

"==== Windows 日常清理日志 ====" | Out-File $LogFile -Encoding UTF8
"时间: $(Get-Date -Format R)`n" | Out-File $LogFile -Append

# 1. 当前用户 TEMP
"## 1. 清理当前用户 TEMP ($env:TEMP)" | Out-File $LogFile -Append
try {
    Get-ChildItem $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    "已清理 $env:TEMP" | Out-File $LogFile -Append
} catch {
    "清理用户 TEMP 失败：$($_.Exception.Message)" | Out-File $LogFile -Append
}
"`n" | Out-File $LogFile -Append

# 2. 系统 TEMP（可选，若非管理员可能部分失败）
"## 2. 清理系统 TEMP (C:\Windows\Temp)" | Out-File $LogFile -Append
try {
    Get-ChildItem "C:\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    "已尝试清理 C:\Windows\Temp（部分文件可能被锁定跳过）。" | Out-File $LogFile -Append
} catch {
    "清理系统 TEMP 失败：$($_.Exception.Message)" | Out-File $LogFile -Append
}
"`n" | Out-File $LogFile -Append

# 3. 清空回收站
"## 3. 清空回收站" | Out-File $LogFile -Append
try {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    "回收站已清空。" | Out-File $LogFile -Append
} catch {
    "清空回收站失败：$($_.Exception.Message)" | Out-File $LogFile -Append
}
"`n" | Out-File $LogFile -Append

# 4. 当前磁盘使用情况
"## 4. 当前磁盘使用情况" | Out-File $LogFile -Append
Get-CimInstance Win32_LogicalDisk |
    Select-Object DeviceID, Size, FreeSpace |
    Format-Table -AutoSize | Out-String | Out-File $LogFile -Append
"`n" | Out-File $LogFile -Append

"✅ 清理完成，详情日志：$LogFile" | Out-File $LogFile -Append
Write-Host "✅ 清理完成，详情日志：$LogFile"
