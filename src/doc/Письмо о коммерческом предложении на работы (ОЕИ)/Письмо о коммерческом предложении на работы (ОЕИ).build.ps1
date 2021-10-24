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

task clean {
	Remove-BuildItem $DestinationDocumentPath, $PreprocessedDocumentPath;
};

task 'ОРД ФБУ Тест-С.-Петербург v2.ott' {
	Invoke-Build BuildTemplate -File "$SourceTemplatesPath/ОРД ФБУ Тест-С.-Петербург v2.ott/ОРД.build.ps1" @parameters;
};

openDocument 'BuildDoc-Письмо.odt' `
	-LiteralPath "$SourceDocumentPath/Письмо.odt" `
	-PreprocessedPath "$PreprocessedDocumentPath/Письмо.odt" `
	-LibrariesPath $DestinationLibrariesPath `
	-TemplatesPath $PreprocessedTemplatesPath `
	-Version $Version `
	-Inputs @( Get-ChildItem -Path "$SourceDocumentPath/Письмо.odt" -File -Recurse -Exclude $MarkerFileName ) `
	-Outputs @( "$DestinationDocumentPath/Письмо.odt", "$DestinationDocumentPath/$MarkerFileName" ) `
	-Jobs 'ОРД ФБУ Тест-С.-Петербург v2.ott';

openDocument 'BuildAndOpenDoc-Письмо.odt' `
	-OpenAfterBuild `
	-LiteralPath "$SourceDocumentPath/Письмо.odt" `
	-PreprocessedPath "$PreprocessedDocumentPath/Письмо.odt" `
	-LibrariesPath $DestinationLibrariesPath `
	-TemplatesPath $PreprocessedTemplatesPath `
	-Version $Version `
	-Inputs @( Get-ChildItem -Path "$SourceDocumentPath/Письмо.odt" -File -Recurse -Exclude $MarkerFileName ) `
	-Outputs @( "$DestinationDocumentPath/Письмо.odt", "$DestinationDocumentPath/$MarkerFileName" ) `
	-Jobs 'ОРД ФБУ Тест-С.-Петербург v2.ott';

task BuildDoc 'BuildDoc-Письмо.odt';

task BuildAndOpenDoc 'BuildAndOpenDoc-Письмо.odt';

task . BuildDoc;
