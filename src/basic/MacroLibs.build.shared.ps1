# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

Set-StrictMode -Version Latest;

$InvocationInfo = @( Get-PSCallStack )[0].InvocationInfo;

[System.String] $LibDir = $InvocationInfo.PSScriptRoot;

if ( -not ( Test-Path variable:LibName ) -or ( [System.String]::IsNullOrEmpty( $LibName ) ) )
{
	$LibName = Split-Path -Path $LibDir -Leaf;
};

if ( -not [System.IO.Path]::IsPathRooted( $DestinationLibrariesPath ) )
{
	$DestinationLibrariesPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$RepoRootPath/$DestinationLibrariesPath" );
};
[System.String] $DestinationLibraryPath = ( Join-Path -Path $DestinationLibrariesPath -ChildPath $LibName );

if ( -not [System.IO.Path]::IsPathRooted( $DestinationLibContainersPath ) )
{
	$DestinationLibContainersPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$RepoRootPath/$DestinationLibContainersPath" );
};
[System.String] $DestinationLibContainerPath = ( Join-Path -Path $DestinationLibContainersPath -ChildPath $LibName );

if ( -not [System.IO.Path]::IsPathRooted( $SourceLibrariesPath ) )
{
	$SourceLibrariesPath = ( Join-Path -Path $RepoRootPath -ChildPath $SourceLibrariesPath -Resolve );
};
[System.String] $SourceLibraryPath = ( Join-Path -Path $LibDir -ChildPath 'src' -Resolve );


$prerequisites = @( Get-ChildItem -Path $SourceLibraryPath -File -Recurse );
$scriptsLibFile = Join-Path -Path $DestinationLibraryPath -ChildPath 'script.xlb';
$targetFiles = @(
	$prerequisites | Where-Object { $_.Extension -eq '.bas' } `
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
	$prerequisites | Where-Object { $_.Extension -eq '.bas' } `
	| ForEach-Object { [System.IO.Path]::ChangeExtension( $_.FullName, '.xml' ) } `
	| ForEach-Object { $_.Replace( $SourceLibraryPath, $targetContainerBasicLib ) }
);


[System.String] $ToolsPath = ( Resolve-Path -Path $RepoRootPath/tools ).Path;
[System.String] $DocsToolsPath = ( Resolve-Path -Path $ToolsPath/docs ).Path;

[System.String] $BuildOOMacroLibPath = ( Resolve-Path -Path $DocsToolsPath/Build-OOMacroLib.ps1 ).Path;

[System.String] $BuildOOMacroLibContainerPath = ( Resolve-Path -Path $DocsToolsPath/Build-OOMacroLibContainer.ps1 ).Path;

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
