<#
	.SYNOPSIS
		Преобразовать open office файлов в папки с xml файлами для последующего
		хранения в git репозиториях
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	# путь к каталогу с Open Office файлами
	[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $true )]
	[System.String]
	$Path,

	# путь к папке, в которой будут созданы папки с xml файлами
	[Parameter( Mandatory = $True, Position = 1, ValueFromPipeline = $false )]
	[Alias( "Directory" )]
	[System.String]
	$DestinationPath,

	# форматировать структуру xml файлов
	[Parameter( ValueFromPipeline = $false )]
	[Switch]
	$Indented
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

Get-ChildItem -Path $Path -Filter '*.ott' `
| Resolve-Path -Relative `
| . ( Join-Path -Path $PSScriptRoot -ChildPath 'ConvertTo-PlainXML.ps1' ) `
	-DestinationPath $DestinationPath `
	-Indented:( $PSCmdlet.MyInvocation.BoundParameters.Indented.IsPresent -eq $true ) `
	-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
	-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
