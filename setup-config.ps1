#Requires -RunAsAdministrator

param(
    [bool]$Uninstall = $false
)

function Set-Property {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Settings,
        [Parameter(Mandatory = $true)]
        [string]$Field,
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    if($null -eq $Settings.$Field) {
        $Settings | Add-Member -NotePropertyName $Field -NotePropertyValue $Value
    } else {
        $Settings.$Field = $Value
    }
}


# check if we\re running as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You need to run this script as an administrator"
    return
}

if($Uninstall) {
    "Uninstalling..."

    oh-my-posh font uninstall "CascadiaCode"
    oh-my-posh font uninstall "FiraCode"

    choco uninstall -y git nushell vscode-insiders oh-my-posh

    "Uninstalled"
    return
} else {
    "Installing..."
    
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
    choco install -y git vscode-insiders oh-my-posh nushell
    $env:Path += ";$env:LOCALAPPDATA\Programs\oh-my-posh\bin"

    oh-my-posh font install "CascadiaCode" 
    oh-my-posh font install "FiraCode" 

    # Set Windows Terminal settings
    $settingsFilePath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $colorScheme = "One Half Dark"
    $fontFace = "CaskaydiaMono Nerd Font Mono"
    $opacity = 80
    $useAcrylic = $true

    # Update Windows Terminal settings
    $settings = Get-Content $settingsFilePath | ConvertFrom-Json


    if ($settings.profiles.defaults -eq $null) {
        $settings.profiles.defaults = @{}
    }
    

    Set-Property -Settings $settings.profiles.defaults -Field "colorScheme" -Value $colorScheme
    Set-Property -Settings $settings.profiles.defaults -Field "font.face" -Value $fontFace
    Set-Property -Settings $settings.profiles.defaults -Field "opacity" -Value $opacity
    Set-Property -Settings $settings.profiles.defaults -Field "useAcrylic" -Value $useAcrylic
    
    $updatedSettings = $settings | ConvertTo-Json -Depth 50
    $updatedSettings | Set-Content $settingsFilePath

    # Download & Install theme for Nushell
    $theme = "catppuccin_frappe"
    $themeURL = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$theme.omp.json"
    $themePath = "$env:APPDATA\nushell\themes\$theme.omp.json"
    New-Item -ItemType Directory -Force -Path "$env:APPDATA\nushell\themes"
    Invoke-WebRequest -Uri "$themeURL" -OutFile "$themePath"

    # setup an oh-my-posh config for nushell
    oh-my-posh init nu --config $themePath
    # add the oh-my-posh config to the nushell config
    "source ~/.oh-my-posh.nu" | Add-Content -Path "$env:APPDATA\nushell\config.nu"

}