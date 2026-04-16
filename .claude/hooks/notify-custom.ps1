param(
    [string]$Title = "Claude Code",
    [string]$Message = "Notification",
    [ValidateSet('Info','Warning','Error')]
    [string]$Type = 'Info',
    [int]$Duration = 8
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create form
$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = 'None'
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.Size = New-Object System.Drawing.Size(350, 100)
$form.StartPosition = 'Manual'
$form.TopMost = $true
$form.ShowInTaskbar = $false

# Position at bottom-right of screen
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$form.Location = New-Object System.Drawing.Point(($screen.Right - $form.Width - 20), ($screen.Bottom - $form.Height - 20))

# Title label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = $Title
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.Location = New-Object System.Drawing.Point(15, 10)
$titleLabel.Size = New-Object System.Drawing.Size(320, 25)
$form.Controls.Add($titleLabel)

# Message label
$messageLabel = New-Object System.Windows.Forms.Label
$messageLabel.Text = $Message
$messageLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$messageLabel.ForeColor = [System.Drawing.Color]::LightGray
$messageLabel.Location = New-Object System.Drawing.Point(15, 35)
$messageLabel.Size = New-Object System.Drawing.Size(320, 50)
$messageLabel.AutoSize = $false
$form.Controls.Add($messageLabel)

# Color bar based on type
$colorBar = New-Object System.Windows.Forms.Panel
$colorBar.Size = New-Object System.Drawing.Size(5, 100)
$colorBar.Location = New-Object System.Drawing.Point(0, 0)
$colorBar.BackColor = switch ($Type) {
    'Warning' { [System.Drawing.Color]::Orange }
    'Error'   { [System.Drawing.Color]::Red }
    default   { [System.Drawing.Color]::DodgerBlue }
}
$form.Controls.Add($colorBar)

# Timer to auto-close
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = ($Duration * 1000)
$timer.Add_Tick({
    $form.Close()
    $timer.Stop()
})
$timer.Start()

# Click to close
$form.Add_Click({ $form.Close() })
$titleLabel.Add_Click({ $form.Close() })
$messageLabel.Add_Click({ $form.Close() })

# Fade in animation
$form.Opacity = 0
$form.Show()

$fadeTimer = New-Object System.Windows.Forms.Timer
$fadeTimer.Interval = 50
$fadeTimer.Add_Tick({
    if ($form.Opacity -lt 0.95) {
        $form.Opacity += 0.15
    } else {
        $form.Opacity = 0.95
        $fadeTimer.Stop()
    }
})
$fadeTimer.Start()

# Keep form open
[System.Windows.Forms.Application]::Run($form)
