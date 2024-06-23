; https://mapaction.atlassian.net/wiki/spaces/softwaredevcircle/pages/14122678636/MapAction+Toolbar+Installation+for+ArcGIS+Pro
; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "MapAction ArcGIS Pro Toolbar"
#define MyAppVersion "3.1.3.2"
#define MyAppPublisher "MapAction"
#define MyAppURL "https://www.mapaction.org"
#define MyAppExeName "MyProg.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{40424AA0-930D-4A40-9464-926878F1644F}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
CreateAppDir=no
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
OutputDir=output
OutputBaseFilename=MapActionToolbarArcGISProUserSetup-v{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
Uninstallable=no
SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "MapActionToolbarInstaller.ps1"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "MapActionToolbars.esriAddinX"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "requirements.txt"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "..\MapActionToolbars\Python\*.pyt"; DestDir: "{tmp}\python"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Run]
; %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe                       
; powershell.exe -noprofile -executionpolicy bypass -file "D:\code\github\mapaction-toolbox-arcgis-pro\installer\MapActionToolbarInstaller.ps1"
; Update ISS file to handle copying files around.
; Filename: "{win}\system32\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-noprofile -executionpolicy bypass -file {tmp}\MapActionToolbarInstaller.ps1" ; Flags: runasoriginaluser runhidden; StatusMsg: "Configuring ArcGIS Pro conda environment"
Filename: "{win}\system32\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-noprofile -executionpolicy bypass -file {tmp}\MapActionToolbarInstaller.ps1" ; Flags: runasoriginaluser; StatusMsg: "Configuring ArcGIS Pro conda environment"