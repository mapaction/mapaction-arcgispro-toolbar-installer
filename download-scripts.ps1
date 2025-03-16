$scripts_version = "3.3.0.3"
$scripts_name = "scripts.zip"
$scripts_url = "https://github.com/felnne/mapaction-arcgispro-toolbar/releases/download/$scripts_version/$scripts_name"
$scripts_dir = '.\scripts'

if (-not (Test-Path $scripts_dir)) {
    New-Item -ItemType Directory -Path $scripts_dir
}

Invoke-WebRequest -Uri $scripts_url -OutFile .\$scripts_name
Expand-Archive -Path $scripts_name -DestinationPath $scripts_dir
Remove-Item -Path $scripts_name -Force
Write-Output "[Info] scripts downloaded to .\scripts"
