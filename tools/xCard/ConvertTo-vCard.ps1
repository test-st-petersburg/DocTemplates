# Copyright © 2020 Sergei S. Betke

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
			$xCardSchemaPath = ( Join-Path -Path $PSScriptRoot -ChildPath 'xsd/xCard.xsd' );
			$Schemas.Add( 'urn:ietf:params:xml:ns:vcard-4.0', $xCardSchemaPath ) | Out-Null; ;
			$_.Schemas = $Schemas;
			try
			{
				$_.Validate( $null );
				return $true;
			}
			catch
			{
				Write-Verbose $_.Exception.Message;
				return $false;
			};
		} ) ]
	[System.Xml.XmlDocument]
	$xCard,

	# Версия формата vCard
	[Parameter( Mandatory = $False )]
	[System.Int16]
	$Version = 4
)

begin
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	[System.Xml.Schema.XmlSchemaSet] $Schemas = New-Object System.Xml.Schema.XmlSchemaSet;
	$xCardSchemaPath = ( Join-Path -Path $PSScriptRoot -ChildPath 'xsd/xCard.xsd' );
	$Schemas.Add( 'urn:ietf:params:xml:ns:vcard-4.0', $xCardSchemaPath ) | Out-Null;

	Push-Location -Path $PSScriptRoot;
	$saxExecutable = .\..\Get-XSLTExecutable.ps1 `
		-Path 'xslt\ConvertTo-vCard.xslt' `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
	Pop-Location;
}
process
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	$saxTransform = $saxExecutable.Load30();

	$xCard.Schemas = $Schemas;
	$xCardStream = New-Object System.IO.MemoryStream;
	$xCardStreamWriter = New-Object System.IO.StreamWriter -ArgumentList $xCardStream;
	$xCardStreamWriter.Write( $xCard.InnerXml );
	$xCardStreamWriter.Flush();
	$xCardStream.Position = 0;

	$vCardSerializer = New-Object Saxon.Api.Serializer;
	$vCardWriter = New-Object System.IO.StringWriter;
	$vCardSerializer.SetOutputWriter( $vCardWriter );
	$saxTransform.ApplyTemplates( $xCardStream, $vCardSerializer );

	return $vCardWriter.ToString();
}
