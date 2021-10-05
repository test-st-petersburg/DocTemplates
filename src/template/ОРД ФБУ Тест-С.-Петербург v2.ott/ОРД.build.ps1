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

. $PSScriptRoot/../OpenDocumentTemplates.build.shared.ps1

task Clean {
	Remove-BuildItem $DestinationTemplatePath, $PreprocessedTemplatePath;
};

task BuildLib-TestStPetersburg {
	# TODO: решить вопросы с передачей параметров вызываемому сценарию
	Invoke-Build BuildLib -File $PSScriptRoot/../../basic/TestStPetersburg/TestStPetersburg.build.ps1 `
		-RepoRootPath $RepoRootPath `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
};

task BuildTemplate `
	-Inputs $prerequisites `
	-Outputs @( $DestinationTemplatePath, $marker ) `
	-Job BuildLib-TestStPetersburg, $JobBuildTemplate;

task BuildAndOpenTemplate `
	-Inputs $prerequisites `
	-Outputs @( $DestinationTemplatePath, $marker ) `
	-Job BuildLib-TestStPetersburg, $JobBuildTemplate, $JobOpenFile;

task . BuildTemplate;
