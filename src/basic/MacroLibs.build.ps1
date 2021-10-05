# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0
#Requires -Modules InvokeBuild

param(
	[Parameter( Position = 0 )]
	[System.String[]]
	$Tasks,

	# путь к корневой папке репозитория
	[System.String]
	$RepoRootPath = ( . {
			if ( [System.IO.Path]::GetFileName( $MyInvocation.ScriptName ) -ne 'Invoke-Build.ps1' )
			{
				( Resolve-Path -Path "$PSScriptRoot/../.." ).Path
			}
			else
			{
				( Resolve-Path -Path "$( ( Get-Location ).Path )/../.." ).Path
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

if ( -not [System.IO.Path]::IsPathRooted( $SourceLibrariesPath ) )
{
	$SourceLibrariesPath = ( Join-Path -Path $RepoRootPath -ChildPath $SourceLibrariesPath -Resolve );
};

[System.String[]] $BuildScripts = @(
	$SourceLibrariesPath | Where-Object { Test-Path -Path $_ } |
	Get-ChildItem -Directory |
	Get-ChildItem -File -Filter '*.build.ps1' |
	Select-Object -ExpandProperty FullName
);

# Synopsis: Удаляет каталоги с временными файлами, собранными библиотеками макрокоманд
task Clean {
	foreach ( $BuildScript in $BuildScripts )
	{
		Invoke-Build -Task Clean -File $BuildScript @parameters;
	};
	Remove-BuildItem $DestinationLibrariesPath, $DestinationLibContainersPath;
};

# Synopsis: Создаёт библиотеки макросов Open Office
task BuildLibs {
	foreach ( $BuildScript in $BuildScripts )
	{
		Invoke-Build -Task BuildLib -File $BuildScript @parameters;
	};
};

# Synopsis: Создаёт контейнеры библиотек макросов Open Office для последующей интеграции в шаблоны и документы
task BuildLibContainers {
	foreach ( $BuildScript in $BuildScripts )
	{
		Invoke-Build -Task BuildLibContainer -File $BuildScript @parameters;
	};
};

task . BuildLibs, BuildLibContainers;
