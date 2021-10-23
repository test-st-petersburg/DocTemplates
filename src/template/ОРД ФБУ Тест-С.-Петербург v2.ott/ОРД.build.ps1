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

. $PSScriptRoot/../OpenDocumentTemplates.build.shared.ps1

task Clean {
	Remove-BuildItem $DestinationTemplatePath, $PreprocessedTemplatePath;
};

task BuildLib-TestStPetersburg {
	Invoke-Build BuildLib -File $SourceLibrariesPath/TestStPetersburg/TestStPetersburg.build.ps1 @parameters;
};

openDocumentTemplate BuildTemplate `
	-LiteralPath $SourceTemplatePath `
	-PreprocessedPath $PreprocessedTemplatePath `
	-LibrariesPath $DestinationLibrariesPath `
	-Version $Version `
	-Inputs $sources `
	-Outputs @( $DestinationTemplatePath, $marker ) `
	-Jobs BuildLib-TestStPetersburg;

openDocumentTemplate BuildAndOpenTemplate `
	-OpenAfterBuild `
	-LiteralPath $SourceTemplatePath `
	-PreprocessedPath $PreprocessedTemplatePath `
	-LibrariesPath $DestinationLibrariesPath `
	-Version $Version `
	-Inputs $sources `
	-Outputs @( $DestinationTemplatePath, $marker ) `
	-Jobs BuildLib-TestStPetersburg;

task . BuildTemplate;
