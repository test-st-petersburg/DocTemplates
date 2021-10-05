# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0
#Requires -Modules InvokeBuild
#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.2.0' }

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
	$SourceTemplatesPath | Where-Object { Test-Path -Path $_ } |
	Get-ChildItem -Directory |
	Get-ChildItem -File -Filter '*.build.ps1' |
	Select-Object -ExpandProperty FullName
);

# Synopsis: Удаляет каталоги с временными файлами, собранными шаблонами документов
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

task . BuildTemplates;
