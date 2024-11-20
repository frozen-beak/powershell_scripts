# Path to dir which contains `light` and `dark` wallpaper folders
$wallpaperFolder = "C:\dev\powershell_scripts\images\desktop\"

# Supported themes
enum Theme {
    Dark 
    Light
}

# Fetching system's dateTime info
$currentDateTime = Get-Date
$currentHour = $currentDateTime.Hour

# Decide [currentTheme] with respect to current hour
# if current time is after 7 AM and before 6 PM then light otherwise dark
if ($currentHour -ge 7 -and $currentHour -lt 18) {
    $currentTheme = [Theme]::Light
}
else {
    $currentTheme = [Theme]::Dark
}

# Update wallpaper folder to contain img type path (either [Light] or [Dark])
$wallpaperFolder = "$wallpaperFolder\$currentTheme"

# Update the wallpaper only if the dir exists
if (Test-Path -Path $wallpaperFolder) {
    $images = Get-ChildItem -Path $wallpaperFolder -File
    
    # Check if there are images in the dir
    if ($images.Count -gt 0) {

        # pick a random img from the src dir
        $epochTime = [int][double]::Parse((Get-Date -UFormat %s))
        $randomImage = Get-Random -InputObject $images -SetSeed $epochTime

        $imagePath = $randomImage.FullName
        
        # Win32 API to set wallpaper
        Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        using Microsoft.Win32;
        public class Wallpaper {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
            
            public static void SetWallpaper(string path) {
                SystemParametersInfo(20, 0, path, 0x01 | 0x02);
                RegistryKey key = Registry.CurrentUser.OpenSubKey(@"Control Panel\Desktop", true);
                key.SetValue("WallpaperStyle", "10");
                key.SetValue("TileWallpaper", "0");
                key.Close();
                }
                }
"@

        # Update the wallpaper in the registry for the current user
        [Wallpaper]::SetWallpaper($imagePath)

        Write-Output "[SUCCESS] Image updated successfully; img: [$imagePath]; date: [$currentDateTime];"
    }
    else {
        Write-Output "[ERROR] No image found in [$wallpaperFolder] dir"
    }
}
else {
    Write-Output "[ERROR] Path to the [$wallpaperFolder] does not exists"
}
