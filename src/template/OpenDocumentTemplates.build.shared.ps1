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

Set-Alias openDocumentTemplate Add-BuildOpenDocumentTemplateTask;

function Add-BuildOpenDocumentTemplateTask
(
	[Parameter( Mandatory = $true, Position = 0 )]
	[ValidateNotNullOrEmpty()]
	[System.String] $Name,

	[Parameter( Mandatory = $true )]
	[Alias('PSPath')]
	[Alias('Path')]
	[ValidateNotNullOrEmpty()]
	[System.String] $LiteralPath,

	[Parameter( Mandatory = $false )]
	[ValidateNotNullOrEmpty()]
	[System.String] $PreprocessedPath,

	[Parameter( Mandatory = $false )]
	[Alias('LibPath')]
	[ValidateNotNullOrEmpty()]
	[System.String] $LibrariesPath,

	[Parameter( Mandatory = $false )]
	[System.String] $Version,

	[Parameter( Mandatory = $true, Position = 1 )]
	$Inputs,

	[Parameter( Mandatory = $true, Position = 2 )]
	$Outputs,

	[Parameter()]
	[Switch]
	$OpenAfterBuild,

	[System.Object[]] $Jobs = @(),

	[System.String[]] $After,

	[System.String[]] $Before,

	$If = -9,

	$Done,

	$Source = $MyInvocation
)
{
	$taskParams = @{ SourceTemplatePath = $LiteralPath };
	if ( $PSBoundParameters.Keys.Contains( 'PreprocessedPath' ) )
	{
		$null = $taskParams.Add( 'PreprocessedTemplatePath', $PreprocessedPath );
	};
	if ( $PSBoundParameters.Keys.Contains( 'LibrariesPath' ) )
	{
		$null = $taskParams.Add( 'LibrariesPath', $LibrariesPath );
	};
	if ( $PSBoundParameters.Keys.Contains( 'Version' ) )
	{
		$null = $taskParams.Add( 'Version', $Version );
	};

	$taskJobs = @( 'XSLT-tools' ) + $Jobs;
	$taskJobs += `
	{
		$destFile = $Outputs[0];
		& $BuildOODocumentPath -LiteralPath $Task.Data.SourceTemplatePath -Destination $destFile -Force `
			-PreprocessedPath $Task.Data.PreprocessedTemplatePath `
			-LibrariesPath $Task.Data.LibrariesPath  `
			-Version $Task.Data.Version `
			-WarningAction Continue `
			-Verbose:( $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
			-Debug:( $DebugPreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue );
		$marker = $Outputs[1];
		& $UpdateFileLastWriteTimePath -LiteralPath $marker `
			-Verbose:( $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
			-Debug:( $DebugPreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue );
	};
	if ( $OpenAfterBuild )
	{
		$taskJobs += $JobOpenFile;
	};

	task -Name $Name -Source $Source -Inputs $Inputs -Outputs $Outputs `
		-If $If -Done $Done -Before $Before -After $After `
		-Data $taskParams `
		-Jobs $taskJobs;
}
