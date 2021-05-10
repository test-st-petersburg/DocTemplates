# Copyright © 2021 Sergei S. Betke

#Requires -Version 5.0

<#
	.SYNOPSIS
		Convert xCard to vCard

	.DESCRIPTION
		Convert input xCard (XML) to vCard (string)
#>
[CmdletBinding()]
[OutputType( [System.String] )]

Param(
	# Исходный xCard
	[Parameter( Mandatory = $True, ValueFromPipeline = $True )]
	[ValidateScript( {
			[System.Xml.Schema.XmlSchemaSet] $Schemas = New-Object System.Xml.Schema.XmlSchemaSet;
			$xCardSchemaPath = ( Join-Path -Path $PSScriptRoot -ChildPath 'xCard.xsd' );
			$Schemas.Add( 'urn:ietf:params:xml:ns:vcard-4.0', $xCardSchemaPath ) | Out-Null; ;
			$_.Schemas = $Schemas;
			# try
			# {
			$_.Validate( $null );
			return $true;
			# }
			# catch
			# {
			# 	return $false;
			# };
		} ) ]
	[System.Xml.XmlDocument]
	$Input,

	# Версия формата vCard
	[Parameter( Mandatory = $False )]
	[System.Int16]
	$Version = 4
)

process
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	return '';
}
