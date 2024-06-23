$user_arcpro_root = $Env:LOCALAPPDATA + "\Programs\ArcGIS\Pro"
$machine_arcpro_root = "C:\Program Files\ArcGIS\Pro"

$proExePathSuffix = "\bin\ArcGISPro.exe"
$machineArcGISProExePath = $machine_arcpro_root + $proExePathSuffix
$userArcGISProExePath = $user_arcpro_root + $proExePathSuffix

# Error codes
$errorArcProNotFound = 2
$errorArcProRunning = 4
$errorUnableToSwitchToTargetEnv = 8


###############
# Determine the path to the various elements of ArcGIS Pro are installed
###############
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
    Write-Error("ArcGIS Pro cannot be found")
    exit $errorArcProNotFound
}

###############
# Check if ArcGIS Pro is running
###############
if (Get-Process -Name "ArcGISPro" -ErrorAction:Ignore){
    Write-Output("ArcGIS Pro is running. Installation cannot proceed whilst ArcGIS Pro is running.")
    exit $errorArcProRunning
}

# Now set all of varibles to point to all of the other exes we use
# ESRI provide a wrapper script `propy.bat`, which passes python
# cmds to the currently active conda/python env 
$pythonPath = $arcpro_root + '\bin\Python\Scripts\propy.bat'
$condaEnvPath = $arcpro_root + '\bin\Python\Scripts\conda-env.exe'
$condaPath = $arcpro_root + '\bin\Python\Scripts\conda.exe'
$pythonEnvUtilsPath = $arcpro_root + '\bin\PythonEnvUtils.exe'
# $fullRegAddinPath=$arcpro_root + '\bin\RegisterAddIn.exe'
# $fullArcProExePath = $arcpro_root + $proExePathSuffix

Write-Output("condaEnvPath =" + $condaEnvPath)

#################
# If required create a target conda virtual envionment
#################
$target_venv_name = "mapaction-arc-py3"

# If the MapAction venv does not exist create it:
if (!(& $condaEnvPath list | Select-String -pattern "^$target_venv_name\s")){
    Write-Output("Creating new `conda` env =" + $target_venv_name)
    & $condaPath create -n $target_venv_name --yes --clone arcgispro-py3 
    # & $condaEnvPath create -n $target_venv_name --force
  # _conda_env_exe create --name $target_venv_name --clone arcgispro-py3
}

# Ensure that the $target_venv_name venv is activated and will be activated for future 
# launches of ArcGIS Pro. This uses a custom, non-standard, switch added to ESRI's 
# distribution of Conda
& $condaPath proswap -n $target_venv_name

# Confirm that the the benv has been switched correctly
if (!(& $pythonEnvUtilsPath | Select-String -pattern "$target_venv_name$")){
    Write-Output("Unable to switch to `conda` env =" + $target_venv_name)
    ext $errorUnableToSwitchToTargetEnv
}

# Now install dependancies within our target python env:
# Assumes that `requirements.txt` is in the same directory as this script

# Steve's implenmentation:
# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
# & $fullPythonPath get-pip.py

& $pythonPath -m pip install --no-cache-dir --upgrade pip
& $pythonPath -m pip install --no-cache-dir -r $PSScriptRoot\requirements.txt


##########
# Now ensure that the addin itself is available and registered with ArcGIS Pro.
# There are two components to this.
#
# 1) Create this directory and copy the `esriAddinX` file into it:
#  - "$env:LOCALAPPDATA\MapAction\toolbar-for-arcgispro"
#
# 2) Add a suitable entry in this part of the registry, which directs ArcGIS Pro
#    to look in the directory above:
#  -   'HKCU\SOFTWARE\ESRI\ArcGISPro\Settings\Add-In Folders'
#
# (As of 2021-07-17 we are going to attempt to implenment this without using the `RegisterAddIn.exe` tool)
##########

$assemblyCache_folder = $env:LOCALAPPDATA + "\ESRI\ArcGISPro\AssemblyCache"

if ((Test-Path -PathType "Container" -path $assemblyCache_folder)){
    Remove-Item -LiteralPath $assemblyCache_folder -Force -Recurse
}

$target_addinX_folder = $env:LOCALAPPDATA + "\MapAction\toolbar-for-arcgispro"
$target_reg_path = "HKCU:SOFTWARE\ESRI\ArcGISPro\Settings\Add-In Folders"
$source_addinx_file = $PSScriptRoot + "\MapActionToolbars.esriAddinX"
$source_python_dir = $PSScriptRoot + "\python"
$target_python_dir = $target_addinX_folder + "\python"

# Remove target folder
if ((Test-Path -PathType "Container" -path $target_addinX_folder)){
    Remove-Item -LiteralPath $target_addinX_folder -Force -Recurse
}
# Create the target folder
if (!(Test-Path -PathType "Container" -path $target_addinX_folder)){
    # The `-force` switch means that any intermediate subdirectories are also created
    New-Item -force -itemType "directory" -path $target_addinX_folder
    New-Item -force -itemType "directory" -path $target_python_dir
}

######################################################################################################

$zipRenamed = $source_addinx_file.Replace(".esriAddinX", ".zip")

Rename-Item -Path $source_addinx_file -NewName $zipRenamed
Expand-Archive -LiteralPath $zipRenamed -DestinationPath $PSScriptRoot -Force
Rename-Item -Path $zipRenamed -NewName $source_addinx_file

$extracted_source_python_dir = $PSScriptRoot + "\Install\Python"

$extracted_source_python_dir_with_filter = $extracted_source_python_dir + "/*"
Copy-Item -Path $extracted_source_python_dir_with_filter -Destination $target_python_dir -Recurse -Force -ErrorAction Continue

Remove-Item -LiteralPath ($PSScriptRoot + "\DarkImages") -Force -Recurse
Remove-Item -LiteralPath ($PSScriptRoot + "\Images") -Force -Recurse
Remove-Item -LiteralPath ($PSScriptRoot + "\Install") -Force -Recurse
Remove-Item -LiteralPath ($PSScriptRoot + "\Resources") -Force -Recurse
Remove-Item -LiteralPath ($PSScriptRoot + "\Config.daml") -Force -Recurse

# Copy the .addinX file into the target folder
Copy-item -path $source_addinx_file -destination $target_addinX_folder

# Check that the "Add-In Folder" SubHive exists (this cmd doesn't nothing if the hive already exists)
New-Item -itemType "REG_SZ" -path $target_reg_path -ErrorAction:Ignore
# Add the path to the Addin folder
Set-ItemProperty -path $target_reg_path -name $target_addinX_folder -Type "String" -Value $null