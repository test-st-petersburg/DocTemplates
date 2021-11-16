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

task 'Build-test-spb-nov-branch.vcf' {
	Invoke-Build 'Build-test-spb-nov-branch.vcf' -File $SourceXCardPath/QRCodes.xCards.build.ps1 @parameters;
};

task 'test-spb-nov-branch.vcf' `
	-Inputs @( "$DestinationVCardPath/test-spb-nov-branch.vcf" ) `
	-Outputs @( "$DestinationDocumentPath/test-spb-nov-branch.vcf" ) `
	-Jobs 'Build-test-spb-nov-branch.vcf', {
	Copy-Item -LiteralPath $Inputs[0] -Destination $Outputs[0] -Force;
};

openDocument 'BuildDoc-Письмо.odt' `
	-LiteralPath "$SourceDocumentPath/Письмо.odt" `
	-PreprocessedPath "$PreprocessedDocumentPath/Письмо.odt" `
	-LibrariesPath $DestinationLibrariesPath `
	-TemplatesPath $PreprocessedTemplatesPath `
	-Version $Version `
	-Inputs @( Get-ChildItem -Path "$SourceDocumentPath/Письмо.odt" -File -Recurse -Exclude $MarkerFileName ) `
	-Outputs @( "$DestinationDocumentPath/Письмо.odt", "$DestinationDocumentPath/$MarkerFileName" ) `
	-Jobs 'ОРД ФБУ Тест-С.-Петербург v2.ott', 'test-spb-nov-branch.vcf';

openDocument 'BuildAndOpenDoc-Письмо.odt' `
	-OpenAfterBuild `
	-LiteralPath "$SourceDocumentPath/Письмо.odt" `
	-PreprocessedPath "$PreprocessedDocumentPath/Письмо.odt" `
	-LibrariesPath $DestinationLibrariesPath `
	-TemplatesPath $PreprocessedTemplatesPath `
	-Version $Version `
	-Inputs @( Get-ChildItem -Path "$SourceDocumentPath/Письмо.odt" -File -Recurse -Exclude $MarkerFileName ) `
	-Outputs @( "$DestinationDocumentPath/Письмо.odt", "$DestinationDocumentPath/$MarkerFileName" ) `
	-Jobs 'ОРД ФБУ Тест-С.-Петербург v2.ott', 'test-spb-nov-branch.vcf';

task BuildDoc 'BuildDoc-Письмо.odt';

task BuildAndOpenDoc 'BuildAndOpenDoc-Письмо.odt';

task . BuildDoc;
