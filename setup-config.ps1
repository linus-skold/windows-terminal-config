#Requires -RunAsAdministrator

# check if we\re running as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You need to run this script as an administrator"
    return
}

# Install Chocolatey
$ChocolateyFolder = 'C:\ProgramData\Chocolatey'
if(Test-Path -Path $ChocolateyFolder ) {
    "Chocolatey already installed, skipping."
} else {
    $chocoInstall = Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    if($?) {
        "successfully installed chocolatey"
    } else {
        "failed to install chocolatey"
        return
    }
}

# Install packages
"Starting to install packages"
$gitInstall = choco install -y git
if($?) {
    "successfully installed git"
} else {
    "failed to install git"
    return
}

$codeInstall = choco install -y vscode-insiders
if($?) {
    "successfully installed vscode-insiders"
} else {
    "failed to install vscode-insiders"
    return
}

$ompInstall = choco install -y oh-my-posh
if($?) {
    "successfully installed oh-my-posh"
} else {
    "failed to install oh-my-posh"
    return
}


$cascadiaCodeInstall = oh-my-posh font install "CascadiaCode" 
$firaCodeInstall = oh-my-posh font install "FiraCode" 

# Set Windows Terminal settings
$settingsFilePath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$colorScheme = "One Half Dark"

# Update Windows Terminal settings
$settings = Get-Content $settingsFilePath | ConvertFrom-Json

$settings.profiles.defaults.colorScheme = $colorScheme
$settings.profiles.defaults.font.face = "CaskaydiaMono Nerd Font Mono"
$settings.profiles.defaults.opacity = 80
$settings.profiles.defaults.useAcrylic = true

$updatedSettings = $settings | ConvertTo-Json -Depth 50
$updatedSettings | Set-Content $settingsFilePath

# Install Nushell
$nushellInstall = choco install -y nushell

# Download & Install theme for Nushell
$theme = "catppuccin_frappe"
$themeURL = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$theme.omp.json"
$themePath = "$env:APPDATA\nushell\themes\$theme.omp.json"
$themeDownload = Invoke-WebRequest -Uri "$themeURL" -OutFile "$themePath"


# setup an oh-my-posh config for nushell
oh-my-posh init nu --config $themePath
# add the oh-my-posh config to the nushell config
"source ~/.oh-my-posh.nu" | Add-Content -Path "$env:APPDATA\nushell\config.nu"
