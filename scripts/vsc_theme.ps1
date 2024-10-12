# Path for metadata containg info about last run
# Metadata format ->  date-hour-theme, e.g. 14-20-dark
$metadataFilePath = "C:\dev\powershell_scripts\bin\vsc_theme.txt"

# Path to the vscode's [settings.json] file
$settingsFilePath = "C:\Users\froze\AppData\Roaming\Code\User\settings.json"

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
$currentThemeName = ""

# Decide [currentTheme] and [currentThemeName] with respect to current hour
# if current time is after 7 AM and before 6 PM then light otherwise dark
if ($currentHour -ge 7 -and $currentHour -lt 18) {
    $currentTheme = [Theme]::Light
    $currentThemeName = "Horizon Bright Bold"
}
else {
    $currentTheme = [Theme]::Dark
    $currentThemeName = "Shades of Purple (Super Dark)"
}

# Check if the wallpaper has already been updated for the day and AM/PM status
if (($dateFromFile -eq $currentDate) -and ([string]($currentTheme) -eq $imgTypeFromFile) -and ($hourFromFile -le $currentHour)) {
    # Close the script here because the wallpaper has already been updated
    Write-Output "NOTE: Theme has already been updated today. No changes made."
    return
}

# Check if settings PATH is valid
if (Test-Path -Path $settingsFilePath) {
    try {
        # read [settings.json] file
        $jsonContent = Get-Content -Path $settingsFilePath -Raw | ConvertFrom-Json
        
        if ($jsonContent) {
            # update [workbench.colorTheme] property in [settings.json]
            $jsonContent."workbench.colorTheme" = $currentThemeName
            
            # write to [settings.json] file w/ mutated data
            $jsonContent | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsFilePath
            
            Write-Output "SUCCESS: Updated settings with theme [$currentTheme]."
        }
        else {
            Write-Output "ERROR: Unable to read data from [$settingsFilePath]."
        }
    }
    catch {
        Write-Output "ERROR: An exception occurred while updating the theme: $_"
    }
}
else {
    Write-Output "ERROR: Settings file not found at path [$settingsFilePath]."
}

# Update the metadata
# Metadata format ->  date-hour-theme, e.g. 14-20-dark
Set-Content -Path $metadataFilePath -Value "$currentDate-$currentHour-$currentTheme"
