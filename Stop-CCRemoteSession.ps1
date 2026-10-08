# Stops the Claude Code remote-control session(s) for one specific folder, including any
# --spawn worktree sub-session (which runs under a derived session name/prefix, e.g.
# "PC-folder-1" instead of "PC-folder" - the original exact-match version of this script
# missed those, leaving their process - and its locked working directory - running).
#
# Invoked by the "Stop CC remote session" right-click menu entry, with the folder path as %1.

param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$Path = $Path.TrimEnd('\')
$pc = $env:COMPUTERNAME
$folderName = Split-Path -Path $Path -Leaf
$label = "$pc $folderName"
$prefix = "$pc-$folderName"
$self = $PID

# Prefix match (no closing quote) on purpose: catches derived worktree sub-session names
# like "$prefix-1" too, not just an exact "$prefix" match.
$targets = Get-CimInstance Win32_Process | Where-Object {
    $_.ProcessId -ne $self -and $_.CommandLine -and (
        $_.CommandLine.Contains("--name '$label'") -or
        $_.CommandLine.Contains("--remote-control-session-name-prefix '$prefix") -or
        $_.CommandLine -like "*cc-remote: $folderName*"
    )
}

if (-not $targets) {
    Write-Host "Nothing running for: $label"
    Start-Sleep -Seconds 2
    exit 0
}

foreach ($p in $targets) {
    Write-Host ("Stopping {0} (PID {1})" -f $p.Name, $p.ProcessId)
    & taskkill /PID $p.ProcessId /T /F 2>$null | Out-Null
}

Write-Host "Stopped: $label"
Start-Sleep -Seconds 2
