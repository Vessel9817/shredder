# Escapes single quotes for Linux
function Format-Quotes-Linux() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Str
    )

    return $Str.Replace("'", "'`"'`"'")
}

# Escapes dollar signs for WSL CLI usage
function Format-Dollars-Linux() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Str
    )

    return $Str.Replace('$', '\$')
}

# Escapes backtick and dollar signs for PowerShell
function Format-PowerShell() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Str
    )

    # Order is important!
    return $Str.Replace('`', '``').Replace('$', '`$')
}

# Converts Windows paths to WSL paths
function ConvertTo-Linux-Paths() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$Paths
    )

    # Preventing ACE by escaping paths
    for ($i = 0; $i -lt $Paths.Length; $i++) {
        $Paths[$i] = Format-PowerShell (Format-Quotes-Linux $Paths[$i])
    }

    # Formatting conversion command
    $setPathsCmd = "paths=('" + ($Paths -join "' '") + "')"
    $pathCmd = "$setPathsCmd; for ((i = 0; i < `${#paths[@]}; i++)); do wslpath -u `"`${paths[`$i]}`" 2>/dev/null; done"
    $pathCmd = Format-Dollars-Linux $pathCmd

    # TODO TESTING
    Write-Output $pathCmd

    # Performing conversion
    return (wsl -- eval $pathCmd).Split("`n")
}

# Securely removes files and folders
function Close-And-Shred-Items() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$LinuxPaths
    )

    foreach ($path in $paths) {
        wsl -- find $path -type f -exec shred -uvz {} +
    }
}

# The script entrypoint
function Main() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$WindowsPaths
    )

    # Error handling
    if ($WindowsPaths.Length -lt 1) {
        Write-Error "Usage: win_shredder [paths...]"
        return
    }

    # Fully qualifying paths
    $absPaths = Convert-Path -LiteralPath $WindowsPaths

    if ($absPaths -eq $null) {
        Write-Error "Failed to parse paths. See above error."
        return
    }
    elseif ($absPaths -is [string]) {
        $absPaths = @($absPaths)
    }

    # Shredding files
    ConvertTo-Linux-Paths $absPaths
    #Close-And-Shred-Items (ConvertTo-Linux-Paths $absPaths)
}

# Running entrypoint
Main $args
