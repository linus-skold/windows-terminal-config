#Requires -RunAsAdministrator


param(
    [bool]$Uninstall = $false
)


# check if we\re running as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You need to run this script as an administrator"
    return
}

if($Uninstall) {
    Write-Host "Uninstalling..."

    oh-my-posh font uninstall "CascadiaCode"
    oh-my-posh font uninstall "FiraCode"

    choco uninstall git
    choco uninstall nushell
    choco uninstall vscode-insiders
    choco uninstall oh-my-posh

    Write-Host "Uninstalled"
    return
} else {
    Write-Host "Installing..."
    . "$PSScriptRoot\install.ps1"
}