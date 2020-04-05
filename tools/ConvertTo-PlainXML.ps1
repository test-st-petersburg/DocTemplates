<#
	.SYNOPSIS
		Преобразовать open office файлов в папки с xml файлами для последующего
		хранения в git репозиториях
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	# путь к Open Office файлу
	[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $true )]
	[Alias( "ODT_File" )]
	[Alias( "ODTFile" )]
	[Alias( "OTT_File" )]
	[Alias( "OTTFile" )]
	[System.String]
	$FilePath,

	# путь к папке, в которой будут созданы xml файлы
	[Parameter( Mandatory = $True, Position = 1, ValueFromPipeline = $false )]
	[Alias( "Directory" )]
	[System.String]
	$DestinationPath,

	# форматировать структуру xml файлов
	[Parameter( ValueFromPipeline = $false )]
	[Switch]
	$Indented
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

	$xslt = New-Object System.Xml.Xsl.XslCompiledTransform;
	$xslt.Load( ( Join-Path -Path $PSScriptRoot -ChildPath 'ConvertTo-PlainXML.xslt' ) );
}
process {
	if ( $PSCmdlet.ShouldProcess( $FilePath, "Convert Open Office document to plain XML directory" ) ) {
		$DestinationDirName = ( Get-Item $FilePath ).Name;
		$DestinationPathForFile = Join-Path -Path $DestinationPath -ChildPath $DestinationDirName;
		if ( Test-Path -Path $DestinationPathForFile ) {
			Remove-Item -Path $DestinationPathForFile -Recurse `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};
		if ( -Not ( Test-Path -Path $DestinationPath ) ) {
			New-Item -Path $DestinationPath -ItemType Directory `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};
		$TempZIPFileName = Join-Path `
			-Path ( [System.IO.Path]::GetTempPath() ) `
			-ChildPath ( [System.IO.Path]::GetRandomFileName() );
		$TempZIPFileName = $TempZIPFileName + '.zip';
		Copy-Item -Path $FilePath -Destination $TempZIPFileName `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		$TempXMLFolder = Join-Path `
			-Path ( [System.IO.Path]::GetTempPath() ) `
			-ChildPath ( [System.IO.Path]::GetRandomFileName() );
		$DestinationTempPathForFile = Join-Path -Path $TempXMLFolder -ChildPath $DestinationDirName;
		Expand-Archive -Path $TempZIPFileName -DestinationPath $DestinationTempPathForFile `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		Remove-Item -Path $TempZIPFileName `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

		if ( $Indented ) {
			if ( $PSCmdlet.ShouldProcess( $DestinationPathForFile, "Format all xml files in Open Office document plain XML directory" ) ) {
				Get-ChildItem -Path $DestinationTempPathForFile -Filter '*.xml' -Recurse `
				| Where-Object { $_.Length -gt 0 } `
				| ForEach-Object {
					if ( $PSCmdlet.ShouldProcess( $_, "Format xml file" ) ) {
						$xmlReader = [System.Xml.XmlReader]::Create( $_.FullName, $readerSettings );
						$TempXMLFileName = [System.IO.Path]::GetTempFileName();
						$xmlWriter = [System.Xml.XmlTextWriter]::Create( $TempXMLFileName, $writerSettings );
						$xslt.Transform( $xmlReader, $null, $xmlWriter );
						$xmlReader.Close();
						$xmlWriter.Flush();
						$xmlWriter.Close();
						Move-Item -Path $TempXMLFileName -Destination ( $_.FullName ) -Force `
							-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
							-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
					};
				};
			};
		};

		Copy-Item -Path $DestinationTempPathForFile -Destination $DestinationPath -Recurse `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		Remove-Item -Path $TempXMLFolder -Recurse `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};
}
