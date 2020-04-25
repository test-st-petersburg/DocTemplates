<#
	.SYNOPSIS
		Создаёт open office файлы из папки с xml файлами
#>

#Requires -Version 5.0
#Requires -Modules 7Zip4Powershell

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	# путь к папке с xml файлами
	[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $true )]
	[System.String]
	$Path,

	# путь к папке, в которой будет создан файл Open Office
	[Parameter( Mandatory = $True, Position = 1, ValueFromPipeline = $false )]
	[System.String]
	$DestinationPath,

	# перезаписать существующий файл
	[Parameter()]
	[Switch]
	$Force
)

begin {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	Import-Module 7Zip4Powershell;

	Add-Type -Path ( Join-Path -Path ( Split-Path -Path ( ( Get-Package -Name 'Saxon-HE' ).Source ) -Parent ) -ChildPath 'lib\net40\saxon9he-api.dll' ) `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

	$saxProcessor = New-Object Saxon.Api.Processor;
	$saxCompiler = $saxProcessor.NewXsltCompiler();
	$saxCompiler.BaseUri = $PSScriptRoot;
	Write-Verbose 'Compiling XSLT...';
	try {
		$saxExecutable = $saxCompiler.Compile( ( Join-Path -Path $PSScriptRoot -ChildPath 'ConvertFrom-PlainXML.xslt' ) );
		foreach ( $Error in $saxCompiler.ErrorList ) {
			Write-Warning `
				-Message @"

$($Error.Message)
$( ( [System.Uri]$Error.ModuleUri ).LocalPath ):$($Error.LineNumber) знак:$($Error.ColumnNumber)
"@ `
				-WarningAction Continue;
		};
	}
	catch {
		foreach ( $Error in $saxCompiler.ErrorList ) {
			if ( $Error.isWarning ) {
				Write-Warning `
					-Message @"

$($Error.Message)
$( ( [System.Uri]$Error.ModuleUri ).LocalPath ):$($Error.LineNumber) знак:$($Error.ColumnNumber)
"@ `
					-WarningAction Continue;
			}
			else {
				Write-Error `
					-Message @"

ERROR: $($Error.Message)
$( ( [System.Uri]$Error.ModuleUri ).LocalPath ):$($Error.LineNumber) знак:$($Error.ColumnNumber)
"@ `
					-Exception $Error `
					-ErrorAction Continue;
			};
		};
		Write-Error -Message 'Обнаружены ошибки компиляции XSLT';
	};
	$saxTransform = $saxExecutable.Load();
	Write-Verbose 'XSLT loaded.';
	$saxTransform.SchemaValidationMode = [Saxon.Api.SchemaValidationMode]::Preserve;
	# $saxTransform.RecoveryPolicy = [Saxon.Api.RecoveryPolicy]::DoNotRecover;

	$DTDPath = ( Resolve-Path -Path 'dtd/officedocument/1_0/' ).Path;
}
process {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	if ( $PSCmdlet.ShouldProcess( $DestinationPath, "Create Open Office document from plain XML directory" ) ) {

		$TempXMLFolder = Join-Path `
			-Path ( [System.IO.Path]::GetTempPath() ) `
			-ChildPath ( [System.IO.Path]::GetRandomFileName() );
		$DestinationTempPathForFile = Join-Path -Path $TempXMLFolder -ChildPath $DestinationDirName;
		Copy-Item -Path $Path -Destination $TempXMLFolder -Recurse `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		try {
			if ( $PSCmdlet.ShouldProcess( $DestinationPathForFile, "Unindent all xml source files before build Open Office file" ) ) {
				Get-ChildItem -Path $DestinationTempPathForFile -Filter '*.xml' -Recurse `
				| Where-Object { $_.Length -gt 0 } `
				| ForEach-Object {
					if ( $PSCmdlet.ShouldProcess( $_, "Unindent xml file" ) ) {
						$sourceXMLFileStream = [System.IO.File]::OpenRead( $_.FullName );
						try {
							$saxTransform.SetInputStream( $sourceXMLFileStream, $DTDPath );
							$TempXMLFileName = [System.IO.Path]::GetTempFileName();
							try {
								$saxWriter = $saxProcessor.NewSerializer();
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

			$TempZIPFileName = (
				Join-Path `
					-Path ( [System.IO.Path]::GetTempPath() ) `
					-ChildPath ( [System.IO.Path]::GetRandomFileName() ) `
			) + '.zip';
			try {
				# по требованиям Open Office первым добавляем **без сжатия** файл mimetype
				Compress-7Zip -ArchiveFileName $TempZIPFileName `
					-Path $DestinationTempPathForFile `
					-Filter 'mimetype' `
					-Format Zip `
					-CompressionLevel None `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
				Get-ChildItem -Path $DestinationTempPathForFile -File -Recurse `
					-Exclude 'mimetype' `
				| Compress-7Zip -ArchiveFileName $TempZIPFileName -Append `
					-Format Zip `
					-CompressionLevel Normal -CompressionMethod Deflate `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
				Move-Item -Path $TempZIPFileName `
					-Destination ( Join-Path -Path $DestinationPath -ChildPath ( Split-Path -Path $Path -Leaf ) ) `
					-Force:( $PSCmdlet.MyInvocation.BoundParameters.Force.IsPresent -eq $true ) `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
			}
			finally {
				if ( Test-Path -Path $TempZIPFileName ) {
					Remove-Item -Path $TempZIPFileName -Recurse `
						-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
						-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
				};
			};
		}
		finally {
			Remove-Item -Path $TempXMLFolder -Recurse `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};
	};
};
