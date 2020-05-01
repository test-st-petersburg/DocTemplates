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

	$saxTransform = . ( Join-Path -Path $PSScriptRoot -ChildPath 'Get-XSLTTransform.ps1' ) `
		-LiteralPath ( Join-Path -Path $PSScriptRoot -ChildPath 'ConvertTo-PlainXML.xslt' ) `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
	$saxTransform.SchemaValidationMode = [Saxon.Api.SchemaValidationMode]::Preserve;
	# $saxTransform.RecoveryPolicy = [Saxon.Api.RecoveryPolicy]::DoNotRecover;
	$DTDPath = ( Resolve-Path -Path 'dtd/officedocument/1_0/' ).Path;
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
			$null = New-Item -Path $DestinationPath -ItemType Directory `
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
		try {

			$TempXMLFolder = Join-Path `
				-Path ( [System.IO.Path]::GetTempPath() ) `
				-ChildPath ( [System.IO.Path]::GetRandomFileName() );
			$DestinationTempPathForFile = Join-Path -Path $TempXMLFolder -ChildPath $DestinationDirName;
			Expand-Archive -Path $TempZIPFileName -DestinationPath $DestinationTempPathForFile `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
			try {
				if ( $Indented ) {
					if ( $PSCmdlet.ShouldProcess( $DestinationPathForFile, "Format all xml files in Open Office document plain XML directory" ) ) {
						Get-ChildItem -Path $DestinationTempPathForFile -Filter '*.xml' -Recurse `
						| Where-Object { $_.Length -gt 0 } `
						| ForEach-Object {
							if ( $PSCmdlet.ShouldProcess( $_, "Format xml file" ) ) {
								$sourceXMLFileStream = [System.IO.File]::OpenRead( $_.FullName );
								try {
									$saxTransform.SetInputStream( $sourceXMLFileStream, $DTDPath );

									$TempXMLFileName = [System.IO.Path]::GetTempFileName();
									try {
										$saxWriter = New-Object Saxon.Api.Serializer;
										$saxWriter.SetOutputFile( $TempXMLFileName );
										$saxTransform.Run( $saxWriter );
										$saxWriter.Close();
										Move-Item -Path $TempXMLFileName -Destination ( $_.FullName ) -Force `
											-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
											-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
									}
									finally {
										if ( Test-Path -Path $TempXMLFileName ) {
											Remove-Item -Path $TempXMLFileName -Recurse `
												-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
												-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
										};
									};
								}
								finally {
									$sourceXMLFileStream.Close();
									$sourceXMLFileStream.Dispose();
								};
							};
						};
					};
				};
				Copy-Item -Path $DestinationTempPathForFile -Destination $DestinationPath -Recurse `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
			}
			finally {
				Remove-Item -Path $TempXMLFolder -Recurse `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
			};
		}
		finally {
			Remove-Item -Path $TempZIPFileName `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};
	};
}
