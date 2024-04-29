Run this command in a terminal as admin
```powershell
Invoke-Expression "& { $(Invoke-RestMethod https://raw.githubusercontent.com/linus-skold/windows-terminal-config/main/setup-config.ps1) }"
```
optional parameter `-Uninstall $True|$False`  
Uninstall removes the packages that the script installs. **NOT THE FONTS THOUGH**

This is just my personal setup script for a new windows machine to make it faster to setup my environment.  
I am sure this script will grow in size over time and I don't recommend anyone else to use it.  
This is just to make sure that I can setup everything I need without having to login to github to find a private repo.
