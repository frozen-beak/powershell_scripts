# NOTE: The script runs right after the system boots in, 
# So our script should wait a while to get the system up and running
# 
# NOTE: Adjust it according to your system boot velocity
Start-Sleep 5

# Load and execute each script in order
C:\dev\powershell_scripts\scripts\vsc.ps1
C:\dev\powershell_scripts\scripts\wallpaper.ps1
