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
	$writerSettings.Encoding = [System.Text.Encoding]::UTF8;
	$writerSettings.Indent = $true;
	$writerSettings.IndentChars = "`t";
	$writerSettings.NewLineOnAttributes = $false;
	$writerSettings.NewLineChars = "`r`n";
	$writerSettings.NewLineHandling = [System.Xml.NewLineHandling]::None;
	$writerSettings.OmitXmlDeclaration = $false;
	# $writerSettings.XmlOutputMethod = [System.Xml.XmlOutputMethod]::Xml;
	$writerSettings.WriteEndDocumentOnClose = $true;
	$writerSettings.CloseOutput = $true;
}
process {
	if ( $PSCmdlet.ShouldProcess( $FilePath, "Convert Open Office document to plain XML directory" ) ) {
		$TempZIPFileName = Join-Path `
			-Path ( [System.IO.Path]::GetTempPath() ) `
			-ChildPath ( [System.IO.Path]::GetRandomFileName() );
		$TempZIPFileName = $TempZIPFileName + '.zip';
		Copy-Item -Path $FilePath -Destination $TempZIPFileName `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		$DestinationDirName = ( Get-Item $FilePath ).Name;
		$DestinationPathForFile = Join-Path -Path $DestinationPath -ChildPath $DestinationDirName;
		Expand-Archive -Path $TempZIPFileName -DestinationPath $DestinationPathForFile `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		Remove-Item -Path $TempZIPFileName `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

		if ( $Indented ) {
			if ( $PSCmdlet.ShouldProcess( $DestinationPathForFile, "Format all xml files in Open Office document plain XML directory" ) ) {
				Get-ChildItem -Path $DestinationPathForFile -Filter '*.xml' -Recurse `
				| Where-Object { $_.Length -gt 0 } `
				| ForEach-Object {
					if ( $PSCmdlet.ShouldProcess( $_, "Format xml file" ) ) {
						$xml = New-Object System.Xml.XmlDocument;
						$xmlReader = [System.Xml.XmlReader]::Create( $_.FullName, $readerSettings );
						# $xml.PreserveWhitespace = $true;
						# $xml.XmlResolver = $null;
						$xml.Load( $xmlReader );
						$xmlReader.Close();
						$xmlWriter = [System.Xml.XmlTextWriter]::Create( $_.FullName, $writerSettings );
						$xml.WriteContentTo( $xmlWriter );
						$xmlWriter.Flush();
						$xmlWriter.Close();
					};
				};
			};
		};
	};
}
