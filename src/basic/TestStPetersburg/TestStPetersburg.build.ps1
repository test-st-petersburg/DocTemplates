# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0
#Requires -Modules InvokeBuild

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

. $PSScriptRoot/../MacroLibs.build.shared.ps1

task clean {
	Remove-BuildItem $DestinationLibraryPath, $DestinationLibContainerPath;
};

macrolib BuildLib -LibName $LibName `
	-LiteralPath $SourceLibraryPath -Destination $DestinationLibraryPath `
	-Inputs $sources -Outputs $targetFiles;

macrolibContainer BuildLibContainer -LibName $LibName `
	-LibPath $DestinationLibraryPath -Destination $DestinationLibContainerPath `
	-Inputs $targetFiles -Outputs $targetContainerFiles `
	-Jobs BuildLib;

task . BuildLib, BuildLibContainer;
