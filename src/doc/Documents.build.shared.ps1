# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

Set-StrictMode -Version Latest;

$InvocationInfo = @( Get-PSCallStack )[0].InvocationInfo;

[System.String] $DocumentDir = $InvocationInfo.PSScriptRoot;

if ( -not ( Test-Path variable:DocumentName ) -or ( [System.String]::IsNullOrEmpty( $DocumentName ) ) )
{
	$DocumentName = Split-Path -Path $DocumentDir -Leaf;
};

. $PSScriptRoot/../common.build.shared.ps1

[System.String] $DestinationDocumentPath = ( Join-Path -Path $DestinationDocumentsPath -ChildPath $DocumentName );
[System.String] $PreprocessedDocumentPath = ( Join-Path -Path $PreprocessedDocumentsPath -ChildPath $DocumentName );
[System.String] $SourceDocumentPath = ( Join-Path -Path $DocumentDir -ChildPath 'src' -Resolve );


$sources = @( Get-ChildItem -Path $SourceDocumentPath -File -Recurse -Exclude $MarkerFileName );
$marker = Join-Path -Path $SourceDocumentPath -ChildPath $MarkerFileName;
$targetFiles = @( $DestinationDocumentPath, $marker );


$JobBuildDocument = {

	# TODO: не исправлено!!!

	$destFile = $Outputs[0];
	$marker = $Outputs[1];
	$sourcePath = ( $Inputs | Get-Item | Where-Object -FilterScript { $_.Name -eq 'manifest.xml' } )[0].Directory.FullName | Split-Path -Parent;
	if ( Test-Path -Path $marker )
	{
		Remove-Item -Path $marker `
			-Verbose:( $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue );
	};
	& $BuildOODocumentPath -LiteralPath $sourcePath -Destination $destFile -Force `
		-PreprocessedPath $PreprocessedTemplatePath `
		-LibrariesPath $DestinationLibrariesPath `
		-Version $Version `
		-WarningAction Continue `
		-Verbose:( $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
		-Debug:( $DebugPreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue );
	& $UpdateFileLastWriteTimePath -LiteralPath $marker `
		-Verbose:( $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
		-Debug:( $DebugPreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue );
};
