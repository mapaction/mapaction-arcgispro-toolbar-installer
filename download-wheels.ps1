$python_exe = "envs\mapaction-arc-py3\python.exe"

$python_path = Join-Path $env:USERPROFILE 'AppData\Local\ESRI\conda' 
$python_path = Join-Path $python_path $python_exe 

if (-not (Test-Path $python_path)) {
    $python_path = Join-Path -Path $env:ProgramFiles 'ArcGIS\Pro\bin\Python' 
    $python_path = Join-Path $python_path $python_exe 
}
& $python_path -m pip wheel --no-deps --wheel-dir .\wheels\ -r requirements.txt
Write-Output "[Info] Wheels downloaded to .\wheels"
