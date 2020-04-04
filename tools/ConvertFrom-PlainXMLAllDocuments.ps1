<#
	.SYNOPSIS
		Создаёт open office файлы из папки с xml файлами
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	# путь к папке с xml файлами
	[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $false )]
	[System.String]
	$Path,

	# путь к файлу Open Office, который будет создан
	[Parameter( Mandatory = $True, Position = 1, ValueFromPipeline = $false )]
	[System.String]
	$DestinationPath,

	# перезаписать существующий файл
	[Parameter()]
	[Switch]
	$Force
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

Get-ChildItem -Path $Path `
| Resolve-Path -Relative `
| . ( Join-Path -Path $PSScriptRoot -ChildPath 'ConvertFrom-PlainXML.ps1' ) `
	-DestinationPath $DestinationPath `
	-Force:( $PSCmdlet.MyInvocation.BoundParameters.Force.IsPresent -eq $true ) `
	-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
	-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true ) `
	-WhatIf:( $PSCmdlet.MyInvocation.BoundParameters.WhatIf.IsPresent -eq $true );
