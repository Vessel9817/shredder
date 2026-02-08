Write-Output "Creating shortcut..."
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$env:APPDATA/Microsoft/Windows/SendTo/Shredder.lnk")
$shortcut.TargetPath = "$PSScriptRoot/win_shredder.cmd"
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.Save()

# Requires restart
#Requires -RunAsAdministrator
Write-Output "Securing paging file..."
fsutil behavior set EncryptPagingFile 1> $null

Write-Output "Done! Please restart your device at your convenience."
