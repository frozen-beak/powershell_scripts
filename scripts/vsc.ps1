# Path to dir which contains wallpaper files
$wallpaperFolder = "C:\dev\powershell_scripts\images\vsc\"

$targetFilePath = "C:\dev\powershell_scripts\images\"
$targetFileName = "vsc.jpg"

# Fetching system's dateTime info
$currentDateTime = Get-Date

# Update the wallpaper only if the dir exists
if (Test-Path -Path $wallpaperFolder) {
    $images = Get-ChildItem -Path $wallpaperFolder -File
    
    # Check if there are images in the src dir
    if ($images.Count -gt 0) {
        # pick a random img from the src dir
        $epochTime = [int][double]::Parse((Get-Date -UFormat %s))
        $randomImage = Get-Random -InputObject $images -SetSeed $epochTime

        $imagePath = $randomImage.FullName

        # Deleting previous file
        Remove-Item -Path "$targetFilePath\$targetFileName" -Force

        # Copy a new image into target dir and update its name
        Copy-Item -Path $imagePath -Destination "$targetFilePath\$targetFileName" -Force

        Write-Output "SUCCESS: Image updated successfully; img: [$imagePath]; date: [$currentDateTime];"
    }
    else {
        Write-Output "ERROR: No image found in [$wallpaperFolder] dir"
    }
}
else {
    Write-Output "ERROR: Path to the [$wallpaperFolder] does not exists"
}
