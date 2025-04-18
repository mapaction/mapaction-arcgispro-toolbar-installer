$addin_version = "3.4.2.3"
$addin_name = "MapActionToolbars.esriAddinX"
$addin_url = "https://github.com/mapaction/mapaction-toolbox-arcgis-pro/releases/download/$addin_version/$addin_name"
#$addin_url = "https://github.com/mapaction/mapaction-toolbox-arcgis-pro/releases/download/3.4.2.3/MapActionToolbars.esriAddinX"

Write-Output "[Debug] $addin_url"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Invoke-WebRequest -Uri $addin_url -OutFile $addin_name
Write-Output "[Info] add-in downloaded to .\MapActionToolbars.esriAddinX"
