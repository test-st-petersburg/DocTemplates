# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

Set-StrictMode -Version Latest;

. $PSScriptRoot/../common.build.shared.ps1

$InvocationInfo = @( Get-PSCallStack )[0].InvocationInfo;

[System.String] $LibDir = $InvocationInfo.PSScriptRoot;

if ( -not ( Test-Path variable:LibName ) -or ( [System.String]::IsNullOrEmpty( $LibName ) ) )
{
	$LibName = Split-Path -Path $LibDir -Leaf;
};

[System.String] $DestinationLibraryPath = ( Join-Path -Path $DestinationLibrariesPath -ChildPath $LibName );
[System.String] $DestinationLibContainerPath = ( Join-Path -Path $DestinationLibContainersPath -ChildPath $LibName );
[System.String] $SourceLibraryPath = ( Join-Path -Path $LibDir -ChildPath 'src' -Resolve );

$sources = @( Get-ChildItem -Path $SourceLibraryPath -File -Recurse );
$scriptsLibFile = Join-Path -Path $DestinationLibraryPath -ChildPath 'script.xlb';
$targetFiles = @(
	$sources | Where-Object { $_.Extension -eq '.bas' } `
	| ForEach-Object { [System.IO.Path]::ChangeExtension( $_.FullName, '.xba' ) } `
	| ForEach-Object { $_.Replace( $SourceLibraryPath, $DestinationLibraryPath ) }
) + @( $scriptsLibFile );


$targetContainer = $DestinationLibContainerPath;
$targetContainerBasic = Join-Path -Path $targetContainer -ChildPath 'Basic';
$targetContainerScriptsFile = Join-Path -Path $targetContainerBasic -ChildPath 'script-lc.xml';
$targetContainerBasicLib = Join-Path -Path $targetContainerBasic -ChildPath $LibName;
$targetContainerScriptsLibFile = Join-Path -Path $targetContainerBasicLib -ChildPath 'script-lb.xml';
$targetContainerMeta = Join-Path -Path $targetContainer -ChildPath 'META-INF';
$targetContainerManifest = Join-Path -Path $targetContainerMeta -ChildPath 'manifest.xml';
$targetContainerFiles = ( $targetContainerManifest, $targetContainerScriptsLibFile, $targetContainerScriptsFile ) + @(
	$sources | Where-Object { $_.Extension -eq '.bas' } `
	| ForEach-Object { [System.IO.Path]::ChangeExtension( $_.FullName, '.xml' ) } `
	| ForEach-Object { $_.Replace( $SourceLibraryPath, $targetContainerBasicLib ) }
);


Set-Alias macrolib Add-BuildMacroLibTask;

function Add-BuildMacroLibTask
(
	[Parameter( Mandatory = $true, Position = 0 )]
	[ValidateNotNullOrEmpty()]
	[System.String] $Name,

	[Parameter( Mandatory = $true )]
	[ValidateNotNullOrEmpty()]
	[System.String] $LibName,

	[Parameter( Mandatory = $True )]
	[Alias('PSPath')]
	[Alias('Path')]
	[ValidateNotNullOrEmpty()]
	[System.String] $LiteralPath,

	[Parameter( Mandatory = $true )]
	[ValidateNotNullOrEmpty()]
	[System.String] $Destination,

	[Parameter( Mandatory = $true, Position = 1 )]
	$Inputs,

	[Parameter( Mandatory = $true, Position = 2 )]
	$Outputs,

	[System.Object[]] $Jobs = @(),

	[System.String[]] $After,

	[System.String[]] $Before,

	$If = -9,

	$Done,

	$Source = $MyInvocation
)
{
	task -Name $Name -Source $Source -Inputs $Inputs -Outputs $Outputs `
		-If $If -Done $Done -Before $Before -After $After `
		-Data @{ LibName = $LibName; SourceLibFolder = $LiteralPath; Destination = $Destination; } `
		-Jobs ( $Jobs + `
		{
			& $BuildOOMacroLibPath `
				-Path $Task.Data.SourceLibFolder `
				-Destination $Task.Data.Destination `
				-Name $Task.Data.LibName `
				-Force `
				-WarningAction Continue `
				-Verbose:( $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
				-Debug:( $DebugPreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue );
		} )
}


Set-Alias macrolibContainer Add-BuildMacroLibContainerTask;

function Add-BuildMacroLibContainerTask
(
	[Parameter( Mandatory = $true, Position = 0 )]
	[ValidateNotNullOrEmpty()]
	[System.String] $Name,

	[Parameter( Mandatory = $true )]
	[ValidateNotNullOrEmpty()]
	[System.String] $LibName,

	[Parameter( Mandatory = $True )]
	[Alias('PSPath')]
	[Alias('Path')]
	[Alias('LibPath')]
	[ValidateNotNullOrEmpty()]
	[System.String] $LiteralPath,

	[Parameter( Mandatory = $true )]
	[ValidateNotNullOrEmpty()]
	[System.String] $Destination,

	[Parameter( Mandatory = $true, Position = 1 )]
	$Inputs,

	[Parameter( Mandatory = $true, Position = 2 )]
	$Outputs,

	[System.Object[]] $Jobs = @(),

	[System.String[]] $After,

	[System.String[]] $Before,

	$If = -9,

	$Done,

	$Source = $MyInvocation
)
{
	task -Name $Name -Source $Source -Inputs $Inputs -Outputs $Outputs `
		-If $If -Done $Done -Before $Before -After $After `
		-Data @{ LibName = $LibName; LibFolder = $LiteralPath; Destination = $Destination; } `
		-Jobs ( $Jobs + `
		{
			& $BuildOOMacroLibContainerPath `
				-LiteralPath $Task.Data.LibFolder `
				-Destination $Task.Data.Destination `
				-Name $Task.Data.LibName `
				-Force `
				-WarningAction Continue `
				-Verbose:( $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
				-Debug:( $DebugPreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue );
		} )
}
