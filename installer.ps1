$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$env:APPDATA/Microsoft/Windows/SendTo/Shredder.lnk")
$shortcut.TargetPath = "$PSScriptRoot/win_shredder.cmd"
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.Save()
