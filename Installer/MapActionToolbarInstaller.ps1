# Error codes
$errorArcProNotFound = 2
$errorArcProRunning = 4
$errorUnableToSwitchToTargetEnv = 8

Write-Output("## MapAction Toolbar for ArcGIS Pro Installer ##")

###############
# Determine the path to the various elements of ArcGIS Pro are installed
###############
Write-Output("")
Write-Output("## [1/4] Validating ArcGIS Pro installation ##")

$user_arcpro_root = $Env:LOCALAPPDATA + "\Programs\ArcGIS\Pro"
$machine_arcpro_root = "C:\Program Files\ArcGIS\Pro"
$proExePathSuffix = "\bin\ArcGISPro.exe"
$machineArcGISProExePath = $machine_arcpro_root + $proExePathSuffix
$userArcGISProExePath = $user_arcpro_root + $proExePathSuffix

if ((Test-Path -path $userArcGISProExePath) -eq $true)
{
    $arcpro_root = $user_arcpro_root
} 
elseif ((Test-Path -path $machineArcGISProExePath) -eq $true)
{
    $arcpro_root = $machine_arcpro_root
} 
else 
{
    Write-Error("ERROR! ArcGIS Pro not found")
    exit $errorArcProNotFound
}
Write-Information("INFO ArcGIS Pro installation found.")

Write-Output("INFO Validating ArcGIS Pro is not running.")
if (Get-Process -Name "ArcGISPro" -ErrorAction:Ignore){
    Write-Error("ERROR! ArcGIS Pro is running. Quit and try again.")
    exit $errorArcProRunning
}

# Set varibles to point to exes we use
# ESRI provide `propy.bat` which resolves to the currently active conda env 
$pythonPath = $arcpro_root + '\bin\Python\Scripts\propy.bat'
$condaEnvPath = $arcpro_root + '\bin\Python\Scripts\conda-env.exe'
$condaPath = $arcpro_root + '\bin\Python\Scripts\conda.exe'
$pythonEnvUtilsPath = $arcpro_root + '\bin\PythonEnvUtils.exe'
Write-Information("INFO `pythonPath`: " + $pythonPath)
Write-Information("INFO `condaEnvPath`: " + $condaEnvPath)
Write-Information("INFO `condaPath`: " + $condaPath)
Write-Information("INFO `pythonEnvUtilsPath`: " + $pythonEnvUtilsPath)

#################
# If required, create conda virtual envionment
#################
Write-Output("")
Write-Output("## [2/4] Checking Python environment ##")

$target_venv_name = "mapaction-arc-py3"

if (!(& $condaEnvPath list | Select-String -pattern "^$target_venv_name\s")){
    Write-Information("INFO Target conda env: '" + $target_venv_name + "' not found.")

    Write-Information("INFO Cloning default ArcGIS Pro conda env as: '" + $target_venv_name + "'.")
    & $condaPath create -n $target_venv_name --yes --clone arcgispro-py3
}

# Ensure that the $target_venv_name venv is activated and will be activated for future 
# launches of ArcGIS Pro. This uses a custom, non-standard, switch added to ESRI's 
# distribution of Conda
& $condaPath proswap -n $target_venv_name

# Confirm the new env has been switched correctly
if (!(& $pythonEnvUtilsPath | Select-String -pattern "$target_venv_name$")){
    Write-Error("ERROR! Unable to switch to set " + $target_venv_name + " conda environment as default.")
    exit $errorUnableToSwitchToTargetEnv
}

#################
# Install Python dependencies
#################
Write-Output("")
Write-Output("## [3/4] Configuring Python environment ##")

$wheels_dir = $PSScriptRoot + "\wheels"
$wheel_paths = Get-ChildItem -Path "$wheels_dir\*.whl"

Write-Information("INFO Upgrading Pip.")
& $pythonPath -m pip install --no-cache-dir --upgrade pip

Write-Information("INFO Installing Python dependencies.")
foreach ($wheel_path in $wheel_paths) {
    & $pythonPath -m pip install --no-cache-dir --no-deps $wheel_path
}

#################
# Install Esri AddIn dependencies
#################
Write-Output("")
Write-Output("## [4/4] Installing Esri AddIn ##")

# Ensure addin is available and registered with ArcGIS Pro.
#
# There are two components to this:
#
# 1) Create directory and copy the `esriAddinX` file into it:
#  - "$env:LOCALAPPDATA\MapAction\toolbar-for-arcgispro"
#
# 2) Add registry key, which directs ArcGIS Pro to look in the directory above:
#  - "HKCU\SOFTWARE\ESRI\ArcGISPro\Settings\Add-In Folders"

$assemblyCache_folder = $env:LOCALAPPDATA + "\ESRI\ArcGISPro\AssemblyCache"
$target_addinX_folder = $env:LOCALAPPDATA + "\MapAction\toolbar-for-arcgispro"
$target_reg_path = "HKCU:SOFTWARE\ESRI\ArcGISPro\Settings\Add-In Folders"
$source_addinx_file = $PSScriptRoot + "\MapActionToolbars.esriAddinX"
$source_python_dir = $PSScriptRoot + "\python"
$target_python_dir = $target_addinX_folder + "\python"
$zipRenamed = $source_addinx_file.Replace(".esriAddinX", ".zip")
$extracted_source_python_dir = $PSScriptRoot + "\Install\Python"
$extracted_source_python_dir_with_filter = $extracted_source_python_dir + "/*"

# Clean out any existing assembly caches
Write-Information("INFO Removing assembly caches.")
if ((Test-Path -PathType "Container" -path $assemblyCache_folder)){
    Remove-Item -LiteralPath $assemblyCache_folder -Force -Recurse
}

# Remove and recreate target folder
Write-Information("INFO Recreating AddIn directory.")
if ((Test-Path -PathType "Container" -path $target_addinX_folder)){
    Remove-Item -LiteralPath $target_addinX_folder -Force -Recurse
}
if (!(Test-Path -PathType "Container" -path $target_addinX_folder)){
    # The `-force` switch ensures any intermediate subdirectories are also created
    New-Item -force -itemType "directory" -path $target_addinX_folder
    New-Item -force -itemType "directory" -path $target_python_dir
}

# Copy AddIn
Write-Information("INFO Extracting AddIn to directory.")
Rename-Item -Path $source_addinx_file -NewName $zipRenamed
Expand-Archive -LiteralPath $zipRenamed -DestinationPath $PSScriptRoot -Force
Rename-Item -Path $zipRenamed -NewName $source_addinx_file

# Copy Toolboxes
Write-Information("INFO Copying Toolboxes to install directory.")
Copy-Item -Path $extracted_source_python_dir_with_filter -Destination $target_python_dir -Recurse -Force -ErrorAction Continue

# Remove unused files from AddIn
Write-Information("INFO Removing unused AddIn files.")
Remove-Item -LiteralPath ($PSScriptRoot + "\DarkImages") -Force -Recurse
Remove-Item -LiteralPath ($PSScriptRoot + "\Images") -Force -Recurse
Remove-Item -LiteralPath ($PSScriptRoot + "\Install") -Force -Recurse
Remove-Item -LiteralPath ($PSScriptRoot + "\Resources") -Force -Recurse
Remove-Item -LiteralPath ($PSScriptRoot + "\Config.daml") -Force -Recurse

# Copy the .addinX file into the target folder
Write-Information("INFO Copying AddIn to install directory.")
Copy-item -path $source_addinx_file -destination $target_addinX_folder

# Check that the "Add-In Folder" SubHive exists
Write-Information("INFO Configuring registry.")
New-Item -itemType "REG_SZ" -path $target_reg_path -ErrorAction:Ignore
# Add the path to the AddIn folder
Set-ItemProperty -path $target_reg_path -name $target_addinX_folder -Type "String" -Value $null

Write-Output("")
Write-Information("INFO Installation Complete.")
Write-Output("If no errors occurred, you can safely close this window and click 'Finish' in the installation wizard.")
Write-Output("If there were errors, please copy all the text in this window, save as a text file, and send to help-tech on Slack for assistance.")
