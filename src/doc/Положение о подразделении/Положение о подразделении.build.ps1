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

. $PSScriptRoot/../Documents.build.shared.ps1

task Clean {
	Remove-BuildItem $DestinationDocumentPath, $PreprocessedDocumentPath;
};

task 'ОРД ФБУ Тест-С.-Петербург v2.ott' {
	Invoke-Build BuildTemplate -File "$SourceTemplatesPath/ОРД ФБУ Тест-С.-Петербург v2.ott/ОРД.build.ps1" @parameters;
};

openDocument 'BuildDoc-Положение о подразделении.odt' `
	-LiteralPath "$SourceDocumentPath/Положение о подразделении.odt" `
	-PreprocessedPath "$PreprocessedDocumentPath/Положение о подразделении.odt" `
	-LibrariesPath $DestinationLibrariesPath `
	-TemplatesPath $PreprocessedTemplatesPath `
	-Version $Version `
	-Inputs @( Get-ChildItem -Path "$SourceDocumentPath/Положение о подразделении.odt" -File -Recurse -Exclude $MarkerFileName ) `
	-Outputs @( "$DestinationDocumentPath/Положение о подразделении.odt", "$DestinationDocumentPath/$MarkerFileName" ) `
	-Jobs 'ОРД ФБУ Тест-С.-Петербург v2.ott';

openDocument 'BuildAndOpenDoc-Положение о подразделении.odt' `
	-OpenAfterBuild `
	-LiteralPath "$SourceDocumentPath/Положение о подразделении.odt" `
	-PreprocessedPath "$PreprocessedDocumentPath/Положение о подразделении.odt" `
	-LibrariesPath $DestinationLibrariesPath `
	-TemplatesPath $PreprocessedTemplatesPath `
	-Version $Version `
	-Inputs @( Get-ChildItem -Path "$SourceDocumentPath/Положение о подразделении.odt" -File -Recurse -Exclude $MarkerFileName ) `
	-Outputs @( "$DestinationDocumentPath/Положение о подразделении.odt", "$DestinationDocumentPath/$MarkerFileName" ) `
	-Jobs 'ОРД ФБУ Тест-С.-Петербург v2.ott';

task BuildDoc 'BuildDoc-Положение о подразделении.odt';

task BuildAndOpenDoc 'BuildAndOpenDoc-Положение о подразделении.odt';

task . BuildDoc;
