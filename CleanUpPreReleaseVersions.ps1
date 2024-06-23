$per_machine = $false
$user_arcpro_root = $Env:LOCALAPPDATA + "\Programs\ArcGIS\Pro"
$machine_arcpro_root = "C:\Program Files\ArcGIS\Pro"

$proExePathSuffix = "\bin\ArcGISPro.exe"
$machineArcGISProExePath = $machine_arcpro_root + $proExePathSuffix
$userArcGISProExePath = $user_arcpro_root + $proExePathSuffix

# Error codes
$errorArcProNotFound = 2


###############
# Determine the path to the various elements of ArcGIS Pro are installed
###############
if ((Test-Path -path $userArcGISProExePath) -eq $true)
{
    $per_machine = $false
    $arcpro_root = $user_arcpro_root
} 
elseif ((Test-Path -path $machineArcGISProExePath) -eq $true)
{
    $per_machine = $true
    $arcpro_root = $machine_arcpro_root
} 
else 
{
    Write-Error("ArcGIS Pro cannot be found")
    # TODO Exit with error code $errorArcProNotFound
}

$pythonPath = $arcpro_root + '\bin\Python\Scripts\propy.bat'
$condaEnvPath=$arcpro_root + '\bin\Python\Scripts\conda-env.exe'
$condaPath=$arcpro_root + '\bin\Python\Scripts\conda.exe'
$pythonEnvUtilsPath=$arcpro_root + '\bin\PythonEnvUtils.exe'
# $fullRegAddinPath=$arcpro_root + '\bin\RegisterAddIn.exe'
# $fullArcProExePath = $arcpro_root + $proExePathSuffix
$default_venv_name = 'arcgispro-py3'
$target_venv_name = 'mapaction-arc-py3'

###############
#
# First: Attempt to remove the MapAction specifc venv, if it exists. The installer
# will recreate this if required.
#
###############
# Attempt to switch the target venv
& $condaPath proswap -n $target_venv_name

# If switching to the target venv was successful, then remove it 
if (& $pythonEnvUtilsPath | Select-String "$target_venv_name$"){
    & $condaPath remove
}


###############
#
# Secound: Attempt to remove any of the packages that may have been installed in 
# the default conda venv.
#
###############

# TODO: confirm that non of these packages should be inclued in a default 
# installation of ArcGIS Pro.
# The order of this array is the order that the packages will be removed.
# Please ensure that the
$packages_to_remove = @(
    "mapactionpy-arcpro",
    "mapactionpy-controller",
    "mapactionpy-controller-dependencies",
    "mapy-dependencies-py39",
    "mapy-dependencies-py38",
    "mapy-dependencies-py37",
    "mapy-dependencies-py36",
    "mapy-dependencies-py27",
    "Fiona",
    "geopandas",
    "humanfriendly",
    "jsonpickle",
    "pycountry",
    "qrcode",
    "Rtree",
    "Shapely"
    "pyproj",
    "GDAL"
)

& $condaPath proswap -n $default_venv_name


# If switching to the DEFAULT venv was successful, then attempt to remove each of
# relevant packages. 
if (& $pythonEnvUtilsPath | Select-String "$default_venv_name$"){
    ForEach ($pkg In $packages_to_remove){
        & $pythonPath -m pip uninstall --yes $pkg
    }
}
