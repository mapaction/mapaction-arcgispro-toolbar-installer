$python_path = Join-Path $env:USERPROFILE 'AppData\Local\ESRI\conda\envs\mapaction-arc-py3\python.exe'

& $python_path -m pip wheel --no-deps --wheel-dir .\wheels\ -r requirements.txt
Write-Output "[Info] Wheels downloaded to .\wheels"
