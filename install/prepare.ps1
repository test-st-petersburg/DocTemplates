#Requires -Version 5.0
#Requires -RunAsAdministrator
#Requires -Modules PSDesiredStateConfiguration

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

[Net.ServicePointManager]::SecurityProtocol =
[Net.SecurityProtocolType]::Tls12 -bor `
	[Net.SecurityProtocolType]::Tls11 -bor `
	[Net.SecurityProtocolType]::Tls;

$PSDefaultParameterValues = @{
	'*:ErrorAction'                      = [System.Management.Automation.ActionPreference]::Stop;
	'Start-DscConfiguration:Wait'        = $true;
	'Start-DscConfiguration:Verbose'     = $true;
	'Start-LabHostConfiguration:Verbose' = $true;
	'Start-LabConfiguration:Verbose'     = $true;
}

# TODO: через GPO
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted;
#Enable-PSRemoting -Force;

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;
Install-Module PackageManagement -RequiredVersion 1.3.1;
Install-Module PowerShellModule;

$ModulesDir = (Join-Path -Path $PSScriptRoot -ChildPath 'Modules');

Stop-DscConfiguration -Force;

Import-Module (Join-Path -Path $ModulesDir -ChildPath 'xITGPSEnvironment') -Force;
$PSConfigDir = (Join-Path -Path $PSScriptRoot -ChildPath 'PSConfig');
$null = ITGPSEnvironment -OutputPath $PSConfigDir;
Start-DscConfiguration -Path $PSConfigDir;

Import-Module (Join-Path -Path $ModulesDir -ChildPath 'xITGDSCEnvironment') -Force;
$DSCConfigDir = (Join-Path -Path $PSScriptRoot -ChildPath 'DSCConfig');
$null = ITGDSCEnvironment -OutputPath $DSCConfigDir;
Start-DscConfiguration -Path $DSCConfigDir;

. (Join-Path -Path $PSScriptRoot -ChildPath 'xITGODTDevWindowsPC.ps1');
$ConfigDir = (Join-Path -Path $PSScriptRoot -ChildPath 'config');
$null = xITGODTDevWindowsPC -OutputPath $ConfigDir;
Start-DscConfiguration -Path $ConfigDir;
