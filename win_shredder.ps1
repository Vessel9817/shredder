# $DebugPreference = 'Continue'

# Resolves the issue of Write-Debug wrapping text
# https://stackoverflow.com/a/4103885
function global:Write-Debug([string] $Message) {
    if ($DebugPreference -ne 'SilentlyContinue') {
        Write-Host "DEBUG: $Message" -ForegroundColor 'Yellow'
    }
}

# Escapes single quotes for Linux
function Format-Quotes-Linux([string] $Str) {
    return $Str.Replace("'", "'`"'`"'")
}

# Escapes dollar signs for WSL CLI usage
function Format-Dollars-Linux([string] $Str) {
    return $Str.Replace('$', '\$')
}

# Escapes backtick and dollar signs for PowerShell
function Format-PowerShell([string] $Str) {
    # Order is important!
    return $Str.Replace('\', '\\').Replace('`', '\`')
}

# Converts Windows paths to WSL paths
function ConvertTo-Linux-Paths([string[]] $Paths) {
    # Preventing ACE by escaping paths
    for ($i = 0; $i -lt $Paths.Length; $i++) {
        $Paths[$i] = Format-PowerShell (Format-Quotes-Linux $Paths[$i])
    }

    # Formatting conversion command
    # Single quotes are necessary, otherwise $() substitution is a valid ACE target
    $setPathsCmd = "paths=('" + ($Paths -join "' '") + "')"
    $pathCmd = "$setPathsCmd; for ((i = 0; i < `${#paths[@]}; i++)); do wslpath -u \`"`${paths[`$i]}\`" 2>/dev/null; done"
    $pathCmd = Format-Dollars-Linux $pathCmd

    Write-Debug "Generated WSL command:`n$pathCmd"
    Write-Debug "What WSL sees:`n$(wsl -- echo $pathCmd)"

    # Performing conversion
    $paths = (wsl -- eval $pathCmd).Split("`n")

    # Quoting paths, in case they have spaces
    for ($i = 0; $i -lt $paths.Length; $i++) {
        $paths[$i] = "'" + (Format-Quotes-Linux $paths[$i]) + "'"
    }

    return $paths
}

# Securely removes files and folders
function Remove-And-Shred-Files([string[]] $LinuxPaths) {
    foreach ($path in $LinuxPaths) {
        wsl -- eval "find $path -type f -exec shred -uvz {} +"
    }

    # TODO Files have been shredded, now remove (nested) folders
}

# The script entrypoint
function Main([string[]] $WindowsPaths) {
    # Error handling
    if ($WindowsPaths.Length -lt 1) {
        Write-Error "Usage: win_shredder [paths...]"
        return
    }

    # Fully qualifying paths
    $absPaths = Convert-Path -LiteralPath $WindowsPaths

    if ($null -eq $absPaths) {
        Write-Error "Failed to parse paths. See above error."
        return
    }
    elseif ($absPaths -is [string]) {
        $absPaths = @($absPaths)
    }

    # Shredding files
    Remove-And-Shred-Files (ConvertTo-Linux-Paths $absPaths)
}

# Running entrypoint
Main $args
