param(
    [string]$Title = "Claude Code",
    [string]$Message = "Notification"
)

# Play a sound first so you know something happened
[System.Media.SystemSounds]::Exclamation.Play()

# Create balloon notification using NotifyIcon
Add-Type -AssemblyName System.Windows.Forms

$balloon = New-Object System.Windows.Forms.NotifyIcon
$balloon.Icon = [System.Drawing.SystemIcons]::Information
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
$balloon.BalloonTipTitle = $Title
$balloon.BalloonTipText = $Message
$balloon.Visible = $true
$balloon.ShowBalloonTip(5000)

Start-Sleep -Milliseconds 5500
$balloon.Dispose()
