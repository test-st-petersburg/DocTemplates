<#
	.SYNOPSIS
		Преобразовать open office файлов в папки с xml файлами для последующего
		хранения в git репозиториях
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	# путь к Open Office файлу
	[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $false )]
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
	[Parameter()]
	[Switch]
	$Indented
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

if ( $PSCmdlet.ShouldProcess( $FilePath, "Convert Open Office document to plain XML directory" ) ) {
	$TempZIPFileName = [System.IO.Path]::GetTempFileName() + '.zip';
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
			[System.Xml.XmlReaderSettings] $readerSettings = New-Object System.Xml.XmlReaderSettings;
			$readerSettings.ConformanceLevel = [System.Xml.ConformanceLevel]::Document;
			$readerSettings.DtdProcessing = [System.Xml.DtdProcessing]::Parse;
			# не обрабатывать DTD в XML документах
			$readerSettings.XmlResolver = $null;
			$readerSettings.IgnoreComments = $false;
			$readerSettings.IgnoreProcessingInstructions = $false;
			$readerSettings.IgnoreWhitespace = $false;
			$readerSettings.CloseInput = $true;
			Get-ChildItem -Path $DestinationPathForFile -Filter '*.xml' -Recurse `
			| Where-Object { $_.Length -gt 0 } `
			| ForEach-Object {
				Write-Debug "Read xml file $($_.FullName)";
				[System.Xml.XmlDocument] $xml = New-Object System.Xml.XmlDocument;
				[System.Xml.XmlReader] $xmlReader = [System.Xml.XmlReader]::Create( $_.FullName, $readerSettings );
				$xml.PreserveWhitespace = $true;
				$xml.XmlResolver = $null;
				$xml.Load( $xmlReader );
				$xmlReader.Close();
				Write-Verbose "Rewrite (format) xml file $($_.FullName)";
				[System.Xml.XmlTextWriter] $xmlWriter = New-Object System.Xml.XmlTextWriter( $_.FullName, $Null );
				$xmlWriter.Formatting = [System.Xml.Formatting]::Indented;
				$xmlWriter.Indentation = 1;
				$xmlWriter.IndentChar = "`t";
				$xml.WriteContentTo( $xmlWriter );
				$xmlWriter.Flush();
			};
		};
	};
};
