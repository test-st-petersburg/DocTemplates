# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0
#Requires -Modules InvokeBuild

param(
	[Parameter( Position = 0 )]
	[System.String[]]
	$Tasks,

	# путь к папке с генерируемыми файлами
	[System.String]
	$RepoRootPath = ( . {
			if ( [System.IO.Path]::GetFileName( $MyInvocation.ScriptName ) -ne 'Invoke-Build.ps1' )
			{
				( Resolve-Path -Path "$PSScriptRoot/../../.." ).Path
			}
			else
			{
				( Resolve-Path -Path "$( ( Get-Location ).Path )/../../.." ).Path
			};
		}
	),

	# путь к папке с библиотеками макросов
	[System.String]
	$DestinationLibrariesPath = 'output/basic',

	# путь к папке с контейнерами библиотек макросов
	[System.String]
	$DestinationLibContainersPath = 'tmp/basic',

	# путь к папке с исходными файлами библиотек макросов
	[System.String]
	$SourceLibrariesPath = 'src/basic'
)

Set-StrictMode -Version Latest;

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

$parameters = $PSBoundParameters;
$parameters['RepoRootPath'] = $RepoRootPath;

if ( [System.IO.Path]::GetFileName( $MyInvocation.ScriptName ) -ne 'Invoke-Build.ps1' )
{
	Invoke-Build -Task $Tasks -File $MyInvocation.MyCommand.Path @parameters;
	return;
};

. $PSScriptRoot/../MacroLibs.build.shared.ps1

task Clean {
	Remove-BuildItem $DestinationLibraryPath, $DestinationLibContainerPath;
};

task BuildLib -Inputs $prerequisites -Outputs $targetFiles -Job $BuildLibScript;

task BuildLibContainer -Inputs $targetFiles -Outputs $targetContainerFiles -Job BuildLib, $BuildLibContainerScript;

task . BuildLib, BuildLibContainer;
