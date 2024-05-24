#Requires -RunAsAdministrator

param(
    [bool]$Uninstall = $false
)

# check if we\re running as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You need to run this script as an administrator"
    return
}

$chocoPackages = git vscode-insiders oh-my-posh nushell fzf delta

if($Uninstall) {
    "Uninstalling..."

    # oh-my-posh font uninstall "CascadiaCode" # DOESN'T WORK
    # oh-my-posh font uninstall "FiraCode" # DOESN'T WORK

    choco uninstall -y $chocoPackages

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
    choco install -y $chocoPackages    
    
    $env:Path += ";$env:LOCALAPPDATA\Programs\oh-my-posh\bin"

    oh-my-posh font install "CascadiaCode" 
    oh-my-posh font install "FiraCode" 

    # Set Windows Terminal settings
    $settingsFilePath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $colorScheme = "One Half Dark"
    $opacity = 80
    $useAcrylic = $true

    $useAtlasEngine = $true
    $fontFace = "CaskaydiaCove Nerd Font"
    $fontSize = 10.0

    # Update Windows Terminal settings
    $settings = Get-Content $settingsFilePath | ConvertFrom-Json

    $settings.profiles.defaults | Add-Member -NotePropertyName "colorScheme" -NotePropertyValue $colorScheme -Force
    $settings.profiles.defaults | Add-Member -NotePropertyName "opacity" -NotePropertyValue $opacity -Force
    $settings.profiles.defaults | Add-Member -NotePropertyName "useAcrylic" -NotePropertyValue $useAcrylic -Force
    $settings.profiles.defaults | Add-Member -NotePropertyName "useAtlasEngine" -NotePropertyValue $useAtlasEngine -Force
    if($null -eq $settings.profiles.defaults.font) {
        $settings.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue @{} -Force
    }
    $settings.profiles.defaults.font | Add-Member -NotePropertyName "face" -NotePropertyValue $fontFace -Force
    $settings.profiles.defaults.font | Add-Member -NotePropertyName "size" -NotePropertyValue $fontSize -Force
    
    $updatedSettings = $settings | ConvertTo-Json -Depth 50
    $updatedSettings | Set-Content $settingsFilePath

    # Download & Install theme for Nushell
    $theme = "catppuccin_frappe"
    $themeURL = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$theme.omp.json"
    $themePath = "$env:APPDATA\nushell\themes\$theme.omp.json"
    New-Item -ItemType Directory -Force -Path "$env:APPDATA\nushell\themes"
    Invoke-WebRequest -Uri "$themeURL" -OutFile "$themePath"

    $nushellPath = "$env:APPDATA\nushell\"
    #download the default config and env files
    $defaultConfig = "https://raw.githubusercontent.com/nushell/nushell/main/crates/nu-utils/src/sample_config/default_config.nu"
    $defaultEnv = "https://raw.githubusercontent.com/nushell/nushell/main/crates/nu-utils/src/sample_config/default_env.nu"
    Invoke-WebRequest -Uri $defaultConfig -OutFile "$nushellPath\config.nu"
    Invoke-WebRequest -Uri $defaultEnv -OutFile "$nushellPath\env.nu"  

    # setup an oh-my-posh config for nushell
    oh-my-posh init nu --config $themePath
    # add the oh-my-posh config to the nushell config
    "source ~/.oh-my-posh.nu" | Add-Content -Path "$env:APPDATA\nushell\config.nu"

    (Get-Content "$env:APPDATA\nushell\config.nu") -Replace 'show_banner: true', 'show_banner: false' | Set-Content "$env:APPDATA\nushell\config.nu"

    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

    "Reboot your PC for all changes to take effect."
}
