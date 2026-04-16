param(
    [string]$Title = "Claude Code",
    [string]$Message = "Notification"
)

# Log for debugging
Add-Content -Path ".claude/hooks/hook-log.txt" -Value "$(Get-Date): $Message"

# Play sound
[System.Media.SystemSounds]::Exclamation.Play()

# Write a temp script and run it via cmd /c start
$tempScript = "$env:TEMP\claude-notify-$([guid]::NewGuid().ToString('N').Substring(0,8)).ps1"

@"
Add-Type -AssemblyName System.Windows.Forms
`$balloon = New-Object System.Windows.Forms.NotifyIcon
`$balloon.Icon = [System.Drawing.SystemIcons]::Warning
`$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
`$balloon.BalloonTipTitle = "$Title"
`$balloon.BalloonTipText = "$Message"
`$balloon.Visible = `$true
`$balloon.ShowBalloonTip(5000)
Start-Sleep -Seconds 5
`$balloon.Dispose()
Remove-Item -Path '$tempScript' -ErrorAction SilentlyContinue
"@ | Out-File -FilePath $tempScript -Encoding UTF8

cmd /c start /b powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File $tempScript
