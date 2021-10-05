# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

Set-StrictMode -Version Latest;

$InvocationInfo = @( Get-PSCallStack )[0].InvocationInfo;

[System.String] $TemplateDir = $InvocationInfo.PSScriptRoot;

if ( -not ( Test-Path variable:TemplateName ) -or ( [System.String]::IsNullOrEmpty( $TemplateName ) ) )
{
	$TemplateName = Split-Path -Path $TemplateDir -Leaf;
};

. $PSScriptRoot/../common.build.shared.ps1

[System.String] $DestinationTemplatePath = ( Join-Path -Path $DestinationTemplatesPath -ChildPath $TemplateName );
[System.String] $PreprocessedTemplatePath = ( Join-Path -Path $PreprocessedTemplatesPath -ChildPath $TemplateName );
[System.String] $SourceTemplatePath = ( Join-Path -Path $TemplateDir -ChildPath 'src' -Resolve );


$sources = @( Get-ChildItem -Path $SourceTemplatePath -File -Recurse -Exclude $MarkerFileName );
$marker = Join-Path -Path $SourceTemplatePath -ChildPath $MarkerFileName;
$targetFiles = @( $DestinationTemplatePath, $marker );


$JobBuildTemplate = {
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
