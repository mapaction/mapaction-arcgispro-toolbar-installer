$addin_version = "3.4.2.2"
$addin_name = "MapActionToolbars.esriAddinX"
$addin_url = "https://github.com/felnne/mapaction-arcgispro-toolbar/releases/download/$addin_version/$addin_name"
Write-Output "[Debug] $addin_url"

Invoke-WebRequest -Uri $addin_url -OutFile $addin_name
Write-Output "[Info] add-in downloaded to .\MapActionToolbars.esriAddinX"
