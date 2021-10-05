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


$BuildLibScript = {
	$SourceLibFolder = Split-Path -Path $Inputs[0] -Parent;

	& $BuildOOMacroLibPath -Path $SourceLibFolder -Destination $DestinationLibraryPath -Name $LibName -Force `
		-WarningAction Continue `
		-Verbose:( $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
		-Debug:( $DebugPreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue );
};

$BuildLibContainerScript = {
	$LibFolder = ( Split-Path -Path $Inputs[0] -Parent );
	$LibContainerMeta = $Outputs[0];
	$LibContainerPath = ( Split-Path -Path ( Split-Path -Path $LibContainerMeta -Parent ) -Parent );

	& $BuildOOMacroLibContainerPath -LiteralPath $LibFolder -Destination $LibContainerPath -Name $LibName -Force `
		-WarningAction Continue `
		-Verbose:( $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
		-Debug:( $DebugPreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue );
};
