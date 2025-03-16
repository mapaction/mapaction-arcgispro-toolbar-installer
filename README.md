# mapaction-arcgispro-toolbar-installer

MapAction toolbar for ArcGIS Pro installer

## Requirements

- MapAction laptop with:
- PowerShell (to build installer)
- ArcPro (to provide a standard Arc Python environment)
- Inno Setup Compiler (to build installer Exe)

## Reference

### Installer version

Installer version (set in `toolbar-installe.iss`) consists of: `{arcpro-version}.{addin-version}.{installer-version}`.

Where:

- the `addin-version` is relative to the `arcpro-version` (i.e. the 1st, 2nd, 3rd add-in for the particular ArcPro version)
- the `installer-verson` is relative to the `addin-version` in the same way (i.e. the 1st installer for the particular add-in)

E.g. version `2.1.3.1.3` breaks down to:

- ArcPro version: `2.1.3`
- add-in version: `1` (first add-in for version 1.2.3 of ArcPro)
- installer version: `3` (third installer for that add-in)

## Prepare

- upload Add-In to https://github.com/felnne/mapaction-arcgispro-toolbar/releases for `download-addin.ps1` script:
    - name release/tag as per [Installer Version](#installer-version) minus the installer component (e.g. `2.1.3.1`)
    - this is a stop-gap solution until releases are uploaded to the main toolbar project
- check frozen dependencies in `requirements.txt` for `download-wheels.ps1` script
- update `$addin_version` as per [Installer Version](#installer-version) in `download-addin.ps1`
- update `Version` definition as per [Installer Version](#installer-version) in `toolbar-installer.iss`

## Build

From a PowerShell prompt:

```
$ cd \path\to\mapaction-arcgispro-toolbar-installer\
$ powershell -ExecutionPolicy Bypass .\download-wheels.ps1
$ powershell -ExecutionPolicy Bypass .\download-scripts.ps1
$ powershell -ExecutionPolicy Bypass .\download-addin.ps1
$ powershell -ExecutionPolicy Bypass .\build-installer.ps1
```

This should result in populated `wheels/`, `scripts/` and `output/` directories, along with a `MapActionToolbars.esriAddinX` file.

**Note:** Downloaded or compiled files should be ignored by `.gitignore` and must not be committed.

If `build-installer.ps1` fails, open `toolbar-installer.iss` in Inno Setup Compiler and compile manually to debug.

## Distribute

Upload to https://github.com/mapaction/mapaction-arcgispro-toolbar-installer/releases.

## Licence

See `LICENSE`.
