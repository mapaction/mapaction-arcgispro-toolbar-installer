; https://mapaction.atlassian.net/wiki/spaces/softwaredevcircle/pages/14122678636/MapAction+Toolbar+Installation+for+ArcGIS+Pro
; https://jrsoftware.org/ishelp/

#define OrgURL "https://www.mapaction.org"
#define Version "3.4.2.1.2"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{40424AA0-930D-4A40-9464-926878F1644F}
AppName=MapAction Toolbar for ArcGIS Pro
AppVersion={#Version}
AppPublisher=MapAction
AppPublisherURL={#OrgURL}
AppSupportURL={#OrgURL}
AppUpdatesURL={#OrgURL}
CreateAppDir=no
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
OutputDir=output
OutputBaseFilename=MapActionToolbarArcGISProSetup-v{#Version}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
Uninstallable=no
SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "MapActionToolbars.esriAddinX"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "scripts\*.pyt"; DestDir: "{tmp}\python"; Flags: ignoreversion
Source: "wheels\*.whl"; DestDir: "{tmp}\wheels"; Flags: ignoreversion
Source: "requirements.txt"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "toolbar-installer.ps1"; DestDir: "{tmp}"; Flags: ignoreversion

[Run]
Filename: "{win}\system32\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoExit -NoProfile -ExecutionPolicy bypass -file {tmp}\toolbar-installer.ps1" ; Flags: runasoriginaluser; StatusMsg: "Installing MapAction Toolbar for ArcGIS Pro"
