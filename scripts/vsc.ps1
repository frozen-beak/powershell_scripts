# Path for metadata containg info about last run
# Metadata format ->  date-hour-theme, e.g. 14-20
$metadataFilePath = "C:\dev\powershell_scripts\bin\vsc_bg.txt"

# Path to dir which contains wallpaper files
$wallpaperFolder = "C:\dev\powershell_scripts\images\ghibli\"

$targetFilePath = "C:\dev\powershell_scripts\images\"
$targetFileName = "vsc_background.jpg"

# Read and split metadata file
$fileContent = Get-Content -Path $metadataFilePath -Raw
$metaData = $fileContent -split '-'

# Extracting individual components from metadata
$dateFromFile = [int]($metaData[0].Trim())
$hourFromFile = [int]($metaData[1].Trim())

# Fetching system's dateTime info
$currentDateTime = Get-Date
$currentHour = $currentDateTime.Hour
$currentDate = $currentDateTime.Day

# Check if the wallpaper has already been updated for the day and AM/PM status
if (($dateFromFile -eq $currentDate) -and ($hourFromFile -le $currentHour)) {
    return # Close the script here because the wallpaper has already been updated
}

# Update the wallpaper if the dir exists
if (Test-Path -Path $wallpaperFolder) {
    $images = Get-ChildItem -Path $wallpaperFolder -File
    
    # Check if there are images in the dir
    if ($images.Count -gt 0) {
        $randomImage = Get-Random -InputObject $images
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

# Update the metadata
# Metadata format ->  date-hour-theme, e.g. 14-20
Set-Content -Path $metadataFilePath -Value "$currentDate-$currentHour"
