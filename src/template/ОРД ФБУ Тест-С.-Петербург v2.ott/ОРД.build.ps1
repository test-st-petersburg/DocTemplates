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

task clean {
	Remove-BuildItem $DestinationTemplatePath, $PreprocessedTemplatePath;
};

task BuildLib-TestStPetersburg {
	Invoke-Build BuildLib -File $SourceLibrariesPath/TestStPetersburg/TestStPetersburg.build.ps1 @parameters;
};

task Build-rustest.spb.ru.png {
	Invoke-Build Build-rustest.spb.ru.png -File $SourceURIsPath/QRCodes.URI.build.ps1 @parameters;
};

task rustest.spb.ru.png `
	-Inputs @( "$DestinationQRCodesURIPath/rustest.spb.ru.png" ) `
	-Outputs @( "$SourceTemplatePath/Pictures/1000000000000025000000257FD278A9E707D95C.png" ) `
	-Jobs Build-rustest.spb.ru.png, {
	Copy-Item -LiteralPath $Inputs[0] -Destination $Outputs[0] -Force;
};

openDocumentTemplate BuildTemplate `
	-LiteralPath $SourceTemplatePath `
	-PreprocessedPath $PreprocessedTemplatePath `
	-LibrariesPath $DestinationLibrariesPath `
	-Version $Version `
	-Inputs $sources `
	-Outputs @( $DestinationTemplatePath, $marker ) `
	-Jobs BuildLib-TestStPetersburg, rustest.spb.ru.png;

openDocumentTemplate BuildAndOpenTemplate `
	-OpenAfterBuild `
	-LiteralPath $SourceTemplatePath `
	-PreprocessedPath $PreprocessedTemplatePath `
	-LibrariesPath $DestinationLibrariesPath `
	-Version $Version `
	-Inputs $sources `
	-Outputs @( $DestinationTemplatePath, $marker ) `
	-Jobs BuildLib-TestStPetersburg, rustest.spb.ru.png;

task . BuildTemplate;
