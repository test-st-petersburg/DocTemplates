# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0
#Requires -Modules InvokeBuild

param(
	[Parameter( Position = 0 )]
	[System.String[]]
	$Tasks
)

Set-StrictMode -Version Latest;
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

$parameters = $PSBoundParameters;

if ( [System.IO.Path]::GetFileName( $MyInvocation.ScriptName ) -ne 'Invoke-Build.ps1' )
{
	Invoke-Build -Task $Tasks -File $MyInvocation.MyCommand.Path @parameters;
	return;
};

. $PSScriptRoot/../common.build.shared.ps1

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
