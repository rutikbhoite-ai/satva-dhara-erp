#define MyAppName "Satva Dhara ERP"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Satva Dhara"
#define MyAppExeName "satva_dhara_erp.exe"

[Setup]
AppId={{8F5C4D5E-7A6A-4D5D-B4B8-7D7A6D2E91A1}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} v{#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\Satva Dhara ERP
DefaultGroupName=Satva Dhara ERP

OutputDir=installer_output
OutputBaseFilename=Satva_Dhara_ERP_Setup_v1.0.0
SetupIconFile=installer_assets\satva_dhara.ico

WizardStyle=modern
WizardImageFile=installer_assets\welcome.bmp
WizardSmallImageFile=installer_assets\banner.bmp

Compression=lzma2
SolidCompression=yes
LZMAUseSeparateProcess=yes

ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

PrivilegesRequired=admin
DisableProgramGroupPage=no

UninstallDisplayName=Satva Dhara ERP
Uninstallable=yes

VersionInfoVersion=1.0.0.0
VersionInfoCompany=Satva Dhara
VersionInfoDescription=Satva Dhara Farm Management ERP
VersionInfoProductName=Satva Dhara ERP
VersionInfoProductVersion=1.0.0

[Files]
Source: "build\windows\x64\runner\Release\*"; \
    DestDir: "{app}"; \
    Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Satva Dhara ERP"; \
    Filename: "{app}\{#MyAppExeName}"; \
    IconFilename: "{app}\{#MyAppExeName}"

Name: "{commondesktop}\Satva Dhara ERP"; \
    Filename: "{app}\{#MyAppExeName}"; \
    IconFilename: "{app}\{#MyAppExeName}"

[Tasks]
Name: "desktopicon"; \
    Description: "Create a &desktop shortcut"; \
    GroupDescription: "Additional shortcuts:"; \
    Flags: unchecked

[Icons]
Name: "{group}\Satva Dhara ERP"; \
    Filename: "{app}\{#MyAppExeName}"

Name: "{commondesktop}\Satva Dhara ERP"; \
    Filename: "{app}\{#MyAppExeName}"; \
    Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; \
    Description: "Launch Satva Dhara ERP"; \
    Flags: nowait postinstall skipifsilent
