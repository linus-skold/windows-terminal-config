#Requires -RunAsAdministrator

# Install Chocolatey
$ChocolateyFolder = 'C:\ProgramData\Chocolatey'
if(Test-Path -Path $Folder) {
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
$gitInstall = choco install -y git
$codeInstall = choco install -y vscode-insiders
$ompInstall = choco install -y oh-my-posh
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
