$compilerPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
$scriptPath = ".\toolbar-installer.iss"

# Compile the Inno Setup script
Start-Process -FilePath $compilerPath -ArgumentList $scriptPath -Wait -NoNewWindow
