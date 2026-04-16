param(
    [string]$Title = "Claude Code",
    [string]$Message = "Notification",
    [ValidateSet('Info','Warning','Error')]
    [string]$Type = 'Info'
)

Add-Type -AssemblyName System.Windows.Forms

$icon = switch ($Type) {
    'Warning' { [System.Windows.Forms.MessageBoxIcon]::Warning }
    'Error'   { [System.Windows.Forms.MessageBoxIcon]::Error }
    default   { [System.Windows.Forms.MessageBoxIcon]::Information }
}

[System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, $icon)
