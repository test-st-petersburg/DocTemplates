<#
	.SYNOPSIS
		Удаляет мусур в content.xml файлах open office документов
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Medium', SupportsShouldProcess = $true )]
param(
	# путь к content.xml Open Office файлу
	[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $true )]
	[System.String]
	$FilePath
)

begin {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	[System.Xml.XmlReaderSettings] $readerSettings = New-Object System.Xml.XmlReaderSettings;
	$readerSettings.ConformanceLevel = [System.Xml.ConformanceLevel]::Document;
	$readerSettings.DtdProcessing = [System.Xml.DtdProcessing]::Parse;
	# не обрабатывать DTD в XML документах
	$readerSettings.XmlResolver = $null;
	$readerSettings.IgnoreComments = $false;
	$readerSettings.IgnoreProcessingInstructions = $false;
	$readerSettings.IgnoreWhitespace = $false;
	$readerSettings.CloseInput = $true;

	[System.Xml.XmlWriterSettings] $writerSettings = New-Object System.Xml.XmlWriterSettings;
	$writerSettings.ConformanceLevel = [System.Xml.ConformanceLevel]::Document;
	$writerSettings.DoNotEscapeUriAttributes = $false;
	$writerSettings.WriteEndDocumentOnClose = $true;
	$writerSettings.CloseOutput = $true;

	# $xsltFormat = New-Object System.Xml.Xsl.XslCompiledTransform;
	# $xsltFormat.Load( ( Join-Path -Path $PSScriptRoot -ChildPath 'ConvertTo-PlainXML.xslt' ) );

	$xsltOptimize = New-Object System.Xml.Xsl.XslCompiledTransform;
	$xsltOptimize.Load( ( Join-Path -Path $PSScriptRoot -ChildPath 'Optimize-PlainXML.xslt' ) );
}
process {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	if ( $PSCmdlet.ShouldProcess( $FilePath, "Optimize Open Office content.xml" ) ) {
		$TempXMLFileName1 = [System.IO.Path]::GetTempFileName();
		$xmlReader = [System.Xml.XmlReader]::Create( $FilePath, $readerSettings );
		$xmlWriter = [System.Xml.XmlTextWriter]::Create( $TempXMLFileName1, $writerSettings );
		$xsltOptimize.Transform( $xmlReader, $null, $xmlWriter );
		$xmlReader.Close();
		$xmlWriter.Flush();
		$xmlWriter.Close();

		# $TempXMLFileName2 = [System.IO.Path]::GetTempFileName();
		# $xmlReader = [System.Xml.XmlReader]::Create( $TempXMLFileName1, $readerSettings );
		# $xmlWriter = [System.Xml.XmlTextWriter]::Create( $TempXMLFileName2, $writerSettings );
		# $xsltFormat.Transform( $xmlReader, $null, $xmlWriter );
		# $xmlReader.Close();
		# $xmlWriter.Flush();
		# $xmlWriter.Close();

		Move-Item -Path $TempXMLFileName1 -Destination ( $FilePath ) -Force `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

		# Remove-Item -Path $TempXMLFileName1 `
		# 	-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		# 	-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};
}
