# Adds "CC remote session" and "Stop CC remote session" to the right-click menu for folders
# (current user only, no admin needed). Right-clicking a folder and choosing one of them
# starts or stops a named remote-control session for that folder.

$toolDir = "C:\projects\CC remote session folder tool"
$launcher = "$toolDir\Launch-CCRemoteSession.ps1"
$stopper = "$toolDir\Stop-CCRemoteSession.ps1"

foreach ($script in @($launcher, $stopper)) {
    if (-not (Test-Path $script)) {
        throw "Script not found: $script"
    }
}

function Set-MenuEntry($verb, $label, $scriptPath) {
    $keyPath = "Registry::HKEY_CURRENT_USER\Software\Classes\Directory\shell\$verb"
    New-Item -Path $keyPath -Force | Out-Null
    Set-ItemProperty -Path $keyPath -Name "(Default)" -Value $label
    Set-ItemProperty -Path $keyPath -Name "Icon" -Value "powershell.exe"

    $cmdPath = "$keyPath\command"
    New-Item -Path $cmdPath -Force | Out-Null
    Set-ItemProperty -Path $cmdPath -Name "(Default)" -Value "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" `"%1`""
}

Set-MenuEntry "CCRemoteSession" "CC remote session" $launcher
Set-MenuEntry "CCRemoteSessionStop" "Stop CC remote session" $stopper

Write-Host "Installed. Right-click any folder -> CC remote session / Stop CC remote session."
