# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

<#
	.SYNOPSIS
		Write xCard to vcf file

	.DESCRIPTION
		Convert input xCard (XML) to vCard (string) and write it to vcf file
#>
[CmdletBinding( DefaultParameterSetName = 'Path' )]
[OutputType( [System.String] )]

Param(
	# Исходный xCard
	[Parameter( ParameterSetName = 'Xml', Mandatory = $True, ValueFromPipeline = $True, Position = 0 )]
	[ValidateScript( {
			[System.Xml.Schema.XmlSchemaSet] $Schemas = New-Object System.Xml.Schema.XmlSchemaSet;
			$xCardSchemaPath = ( Join-Path -Path $PSScriptRoot -ChildPath 'xsd/xCard.xsd' );
			$Schemas.Add( 'urn:ietf:params:xml:ns:vcard-4.0', $xCardSchemaPath ) | Out-Null;
			$_.Schemas = $Schemas;
			# TODO: восстановить проверку xCard по схеме
			return $true;
			try
			{
				$_.Validate( $null );
				return $true;
			}
			catch
			{
				Write-Error $_.Exception.Message -ErrorAction Continue;
				return $false;
			};
		} ) ]
	[System.Xml.XmlDocument]
	$xCard,

	# xCard filenames
	[Parameter( ParameterSetName = 'Path', Mandatory = $True, Position = 0 )]
	[System.String[]] $Path,

	# xCard single filename
	[Parameter( ParameterSetName = 'LiteralPath', Mandatory = $true, ValueFromPipeline = $true, Position = 0 )]
	[System.String] $LiteralPath,

	# vcf file filename
	[Parameter( Mandatory = $true, Position = 1 )]
	[System.String] $Destination,

	# Версия формата vCard
	[Parameter( Mandatory = $False )]
	[ValidateSet( '4.0' )]
	[System.Version]
	$Version = '4.0',

	# Параметры совместимости генерируемого vCard
	[Parameter( Mandatory = $False )]
	[ValidateSet( 'Android', 'iOS' )]
	[System.String]
	$Compatibility,

	# Минимизировать vCard
	[switch]
	$Minimize
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

$parameters = $PSCmdlet.MyInvocation.BoundParameters;
$null = $parameters.Remove( 'Destination' );

Push-Location -Path $PSScriptRoot;
try
{
	.\ConvertTo-vCard.ps1 @parameters `
	| Out-File -LiteralPath $Destination -Encoding utf8 `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
}
finally
{
	Pop-Location;
};
