# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

<#
	.SYNOPSIS
		Convert xCard to vCard

	.DESCRIPTION
		Convert input xCard (XML) to vCard (string)
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

begin
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	[System.Xml.Schema.XmlSchemaSet] $Schemas = [System.Xml.Schema.XmlSchemaSet]::new();
	$xCardSchemaPath = ( Join-Path -Path $PSScriptRoot -ChildPath 'xsd/xCard.xsd' );
	$Schemas.Add( 'urn:ietf:params:xml:ns:vcard-4.0', $xCardSchemaPath ) | Out-Null;

	$saxProcessor = & $PSScriptRoot/../xslt/Get-XSLTProcessor.ps1 `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

	Write-Verbose 'Создание SAX XSLT 3.0 компилятора.';
	$saxCompiler = $saxProcessor.NewXsltCompiler();

	$TransformerNamespace = 'http://github.com/test-st-petersburg/DocTemplates/tools/xCard/xslt/xCard-to-vCard';
	if ( $Compatibility -eq 'Android' )
	{
		$saxCompiler.SetParameter(
			( [Saxon.Api.QName]::new( $TransformerNamespace, 'max-android-compatibility' ) ),
			( [Saxon.Api.XdmAtomicValue]::new( $true ) )
		);
	};
	$saxCompiler.SetParameter(
		( [Saxon.Api.QName]::new( $TransformerNamespace, 'minimize' ) ),
		( [Saxon.Api.XdmAtomicValue]::new( $Minimize ) )
	);

	$saxExecutable = . ( Join-Path -Path $PSScriptRoot -ChildPath '.\..\xslt\Get-XSLTExecutable.ps1' ) `
		-saxCompiler $saxCompiler `
		-Path 'xslt\ConvertTo-vCard.xslt' `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
}
process
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	if ( $PSCmdlet.ParameterSetName -eq 'Path' )
	{
		$parameters = $PSCmdlet.MyInvocation.BoundParameters;
		$null = $parameters.Remove( 'Path' );
		$Path | Resolve-Path | Select-Object -ExpandProperty Path | ForEach-Object {
			& $PSCmdlet.MyInvocation.MyCommand -LiteralPath $_ @parameters;
		};
	}
	elseif ( $PSCmdlet.ParameterSetName -eq 'LiteralPath' )
	{
		$parameters = $PSCmdlet.MyInvocation.BoundParameters;
		$null = $parameters.Remove( 'LiteralPath' );
		$xCard = [System.Xml.XmlDocument]::new();
		$xCard.Load( $LiteralPath );
		& $PSCmdlet.MyInvocation.MyCommand -xCard $xCard @parameters;
	}
	elseif ( $PSCmdlet.ParameterSetName -eq 'Xml' )
	{
		$saxTransform = $saxExecutable.Load30();

		$xCard.Schemas = $Schemas;
		$xCardStream = [System.IO.MemoryStream]::new();
		$xCardStreamWriter = [System.IO.StreamWriter]::new( $xCardStream, [System.Text.Encoding]::UTF8 );
		$xCardStreamWriter.Write( $xCard.InnerXml );
		$xCardStreamWriter.Flush();
		$xCardStream.Position = 0;

		$vCardStreamWriter = [System.IO.StringWriter]::new();
		$vCardSerializer = [Saxon.Api.Serializer]::new();
		$vCardSerializer.SetOutputWriter( $vCardStreamWriter );

		$saxTransform.ApplyTemplates( $xCardStream, $vCardSerializer );

		$vCardStreamWriter.Flush();
		return $vCardStreamWriter.ToString();
	};
}
