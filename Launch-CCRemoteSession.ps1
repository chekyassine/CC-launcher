# Launches a Claude Code remote-control session for one specific folder.
# Invoked by the "CC remote session" right-click menu entry, with the folder path as %1.

param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$pc = $env:COMPUTERNAME
$folderName = Split-Path -Path $Path -Leaf
$label = "$pc $folderName"
$prefix = "$pc-$folderName"

# Git repo -> isolated worktree per session. Plain local folder -> run in the folder itself.
$spawnMode = if (Test-Path (Join-Path $Path ".git")) { "worktree" } else { "same-dir" }

$running = @(Get-CimInstance Win32_Process |
    Where-Object { $_.CommandLine -match 'remote-control' } |
    ForEach-Object { $_.CommandLine })

$needle = "--name '$label'"
if ($running | Where-Object { $_.Contains($needle) }) {
    Write-Warning "Already running: $label"
    Start-Sleep -Seconds 5
    exit 0
}

$shell = if (Get-Command pwsh -ErrorAction SilentlyContinue) { "pwsh" } else { "powershell" }

Start-Process -FilePath $shell `
    -WorkingDirectory $Path `
    -ArgumentList @(
        "-NoExit",
        "-Command",
        "`$Host.UI.RawUI.WindowTitle = 'cc-remote: $folderName'; claude remote-control --name '$label' --remote-control-session-name-prefix '$prefix' --spawn $spawnMode --permission-mode bypassPermissions --chrome"
    )

Write-Host "Launched: $label ($spawnMode)"
Start-Sleep -Milliseconds 800
