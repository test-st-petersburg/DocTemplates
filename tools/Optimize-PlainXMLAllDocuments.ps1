<#
	.SYNOPSIS
		Удаляет мусур в content.xml файлах open office документов
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Medium', SupportsShouldProcess = $true )]
param(
	# путь к папке, в которой созданы папки с xml файлами
	[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $true )]
	[System.String]
	$Path
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

Get-ChildItem -Path $Path -Directory `
| Resolve-Path -Relative `
| Get-ChildItem -Filter '*.xml' -Recurse `
| Where-Object { $_.Length -gt 0 } `
| Resolve-Path -Relative `
| . ( Join-Path -Path $PSScriptRoot -ChildPath 'Optimize-PlainXML.ps1' ) `
	-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
	-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true ) `
	-WhatIf:( $PSCmdlet.MyInvocation.BoundParameters.WhatIf.IsPresent -eq $true );
