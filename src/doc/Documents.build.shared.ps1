# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

Set-StrictMode -Version Latest;

$InvocationInfo = @( Get-PSCallStack )[0].InvocationInfo;

[System.String] $DocumentDir = $InvocationInfo.PSScriptRoot;

. $PSScriptRoot/../common.build.shared.ps1

if ( -not ( Test-Path variable:DocumentRelativePath ) -or ( [System.String]::IsNullOrEmpty( $DocumentRelativePath ) ) )
{
	Push-Location -LiteralPath $SourceDocumentsPath;
	try
	{
		[System.String] $DocumentRelativePath = ( Resolve-Path -LiteralPath $DocumentDir -Relative );
	}
	finally
	{
		Pop-Location;
	};
};
if ( -not ( Test-Path variable:DocumentTag ) -or ( [System.String]::IsNullOrEmpty( $DocumentTag ) ) )
{
	[System.String] $DocumentTag = $DocumentRelativePath;
};
if ( -not ( Test-Path variable:DocumentName ) -or ( [System.String]::IsNullOrEmpty( $DocumentName ) ) )
{
	$DocumentName = Split-Path -Path $DocumentDir -Leaf;
};

[System.String] $DestinationDocumentPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
	( Join-Path -Path $DestinationDocumentsPath -ChildPath $DocumentRelativePath ) );
[System.String] $PreprocessedDocumentPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
	( Join-Path -Path $PreprocessedDocumentsPath -ChildPath $DocumentRelativePath ) );
[System.String] $SourceDocumentPath = $DocumentDir;


Set-Alias openDocument Add-BuildOpenDocumentTask;

function Add-BuildOpenDocumentTask
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
	[ValidateNotNullOrEmpty()]
	[System.String] $TemplatesPath,

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
	$taskParams = @{ SourceDocumentPath = $LiteralPath };
	if ( $PSBoundParameters.Keys.Contains( 'PreprocessedPath' ) )
	{
		$null = $taskParams.Add( 'PreprocessedDocumentPath', $PreprocessedPath );
	};
	if ( $PSBoundParameters.Keys.Contains( 'LibrariesPath' ) )
	{
		$null = $taskParams.Add( 'LibrariesPath', $LibrariesPath );
	};
	if ( $PSBoundParameters.Keys.Contains( 'TemplatesPath' ) )
	{
		$null = $taskParams.Add( 'TemplatesPath', $TemplatesPath );
	};
	if ( $PSBoundParameters.Keys.Contains( 'Version' ) )
	{
		$null = $taskParams.Add( 'Version', $Version );
	};

	$taskJobs = $Jobs;
	$taskJobs += `
	{
		$destFile = $Outputs[0];
		& $BuildOODocumentPath -LiteralPath $Task.Data.SourceDocumentPath -Destination $destFile -Force `
			-PreprocessedPath $Task.Data.PreprocessedDocumentPath `
			-LibrariesPath $Task.Data.LibrariesPath  `
			-TemplatesPath $Task.Data.TemplatesPath  `
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
