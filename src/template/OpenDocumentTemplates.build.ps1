# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0
#Requires -Modules InvokeBuild
#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.2.0' }

param(
	[Parameter( Position = 0 )]
	[System.String[]]
	$Tasks
)

Set-StrictMode -Version Latest;
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

$parameters = $PSBoundParameters;

if ( [System.IO.Path]::GetFileName( $MyInvocation.ScriptName ) -ne 'Invoke-Build.ps1' )
{
	Invoke-Build -Task $Tasks -File $MyInvocation.MyCommand.Path @parameters;
	return;
};

. $PSScriptRoot/../common.build.shared.ps1

New-BuildSubTask -Tasks clean, BuildTemplate, BuildAndOpenTemplate -Path $SourceTemplatesPath;

task clean {
	Remove-BuildItem $DestinationTemplatesPath, $PreprocessedTemplatesPath;
};

task distclean clean;

task BuildTemplates BuildTemplate;
task BuildAndOpenTemplates BuildAndOpenTemplate;
task . BuildTemplates;
