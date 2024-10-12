# Path for metadata containg info about last run
# Metadata format ->  date-hour-theme, e.g. 14-20-dark
$metadataFilePath = "C:\dev\powershell_scripts\bin\desktop.txt"

# Path to dir which contains `light` and `dark` wallpaper folders
$wallpaperFolder = "C:\dev\powershell_scripts\images\cars\"

# Supported themes
enum Theme {
    Dark 
    Light
}

# Read and split metadata file
$fileContent = Get-Content -Path $metadataFilePath -Raw
$metaData = $fileContent -split '-'

# Extracting individual components from metadata
$dateFromFile = [int]($metaData[0].Trim())
$hourFromFile = [int]($metaData[1].Trim())
$imgTypeFromFile = [string]($metaData[2].Trim())

# Fetching system's dateTime info
$currentDateTime = Get-Date
$currentHour = $currentDateTime.Hour
$currentDate = $currentDateTime.Day
$currentTheme = [Theme]::Light

# Decide [currentTheme] with respect to current hour
# if current time is after 7 AM and before 6 PM then light otherwise dark
if ($currentHour -ge 7 -and $currentHour -lt 18) {
    $currentTheme = [Theme]::Light
}
else {
    $currentTheme = [Theme]::Dark
}

# Check if the wallpaper has already been updated for the day and AM/PM status
if (($dateFromFile -eq $currentDate) -and ([string]($currentTheme) -eq $imgTypeFromFile) -and ($hourFromFile -le $currentHour)) {
    # Close the script here because the wallpaper has already been updated
    return
}

# Update wallpaper folder to contain img type path (either [light] or [dark])
$wallpaperFolder = "$wallpaperFolder\$currentTheme"

# Update the wallpaper if the dir exists
if (Test-Path -Path $wallpaperFolder) {
    $images = Get-ChildItem -Path $wallpaperFolder -File
    
    # Check if there are images in the dir
    if ($images.Count -gt 0) {
        $randomImage = Get-Random -InputObject $images
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
                key.SetValue("WallpaperStyle", "2");
                key.SetValue("TileWallpaper", "0");
                key.Close();
                }
                }
"@

        # Update the wallpaper in the registry for the current user
        [Wallpaper]::SetWallpaper($imagePath)

        Write-Output "SUCCESS: Image updated successfully; img: [$imagePath]; date: [$currentDateTime];"
    }
    else {
        Write-Output "ERROR: No image found in [$wallpaperFolder] dir"
    }
}
else {
    Write-Output "ERROR: Path to the [$wallpaperFolder] does not exists"
}

# Update the metadata
# Metadata format ->  date-hour-theme, e.g. 14-20-dark
Set-Content -Path $metadataFilePath -Value "$currentDate-$currentHour-$currentTheme"
