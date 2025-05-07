$scripts_version = "3.4.2.4"
$scripts_name = "scripts.zip"
$scripts_url = "https://github.com/mapaction/mapaction-toolbox-arcgis-pro/releases/download/$scripts_version/$scripts_name"
$scripts_dir = '.\scripts'

if (-not (Test-Path $scripts_dir)) {
    New-Item -ItemType Directory -Path $scripts_dir
}

Invoke-WebRequest -Uri $scripts_url -OutFile .\$scripts_name
Expand-Archive -Path $scripts_name -DestinationPath $scripts_dir
Remove-Item -Path $scripts_name -Force
Write-Output "[Info] scripts downloaded to .\scripts"
