# Removes the "CC remote session" and "Stop CC remote session" right-click menu entries
# added by Install-ContextMenu.ps1.

foreach ($verb in @("CCRemoteSession", "CCRemoteSessionStop")) {
    $keyPath = "Registry::HKEY_CURRENT_USER\Software\Classes\Directory\shell\$verb"
    if (Test-Path $keyPath) {
        Remove-Item -Path $keyPath -Recurse -Force
        Write-Host "Removed: $verb"
    } else {
        Write-Host "Not installed: $verb"
    }
}
