# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0
#Requires -Modules InvokeBuild
#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.2.0' }

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

	# путь к папке с шаблонами документов
	[System.String]
	$DestinationTemplatesPath = 'output/template',

	# путь к папке с препроцессированными файлами шаблонов документов
	[System.String]
	$PreprocessedTemplatesPath = 'tmp/template',

	# путь к папке с исходными файлами шаблонов документов
	[System.String]
	$SourceTemplatesPath = 'src/template',

	# путь к папке с библиотеками макросов (для внедрения в шаблоны)
	[System.String]
	$LibrariesPath = 'output/basic',

	# версия шаблонов и документов
	[System.String]
	$Version
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

if ( -not [System.IO.Path]::IsPathRooted( $SourceTemplatesPath ) )
{
	$SourceTemplatesPath = ( Join-Path -Path $RepoRootPath -ChildPath $SourceTemplatesPath -Resolve );
};

[System.String[]] $BuildScripts = @(
	$SourceTemplatesPath | Where-Object { Test-Path -Path $_ } |
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
	Remove-BuildItem $DestinationTemplatesPath, $PreprocessedTemplatesPath;
};

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build)
task BuildTemplates {
	foreach ( $BuildScript in $BuildScripts )
	{
		Invoke-Build -Task BuildTemplate -File $BuildScript @parameters;
	};
};

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build) и открывает их
task BuildAndOpenTemplates {
	foreach ( $BuildScript in $BuildScripts )
	{
		Invoke-Build -Task BuildAndOpenTemplate -File $BuildScript @parameters;
	};
};

# TODO: добавить вызов тестов и перенести их в каталоги рядом с build сценариями

task . BuildTemplates;
