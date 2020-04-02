<#
	.SYNOPSIS
		Преобразовать open office файлов в папки с xml файлами для последующего
		хранения в git репозиториях
#>

#Requires -Version 5.0

[CmdletBinding()]
param(
	#
	[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $false)]
	[Alias("ODT_File")]
	[Alias("ODTFile")]
	[Alias("OTT_File")]
	[Alias("OTTFile")]
	[System.String]
	$FilePath,

	[Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $false)]
	[Alias("Directory")]
	[System.String]
	$DestinationPath,

	# форматировать структуру xml файлов
	[Parameter()]
	[Switch]
	$Indented
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

Expand-Archive -Path $FilePath -DestinationPath $DestinationPath;
