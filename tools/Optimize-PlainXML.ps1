<#
	.SYNOPSIS
		Удаляет мусур в content.xml файлах open office документов
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Medium', SupportsShouldProcess = $true )]
param(
	# путь к каталогу с XML файлами Open Office
	[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $true )]
	[System.String]
	$Path
)

begin {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	# Import-Module -Name ( Join-Path -Path $PSScriptRoot -ChildPath 'localXSLT.psm1' );
	# # $saxCompiler.BaseUri = $PSScriptRoot;
	# $saxTransform = Get-XSLTTransform ( Join-Path -Path $PSScriptRoot -ChildPath 'Optimize-PlainXML.xslt' ) `
	# 	-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
	# 	-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

	Add-Type -Path ( Join-Path -Path ( Split-Path -Path ( ( Get-Package -Name 'Saxon-HE' ).Source ) -Parent ) -ChildPath 'lib\net40\saxon9he-api.dll' ) `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

	$saxProcessor = New-Object Saxon.Api.Processor;
	$saxCompiler = $saxProcessor.NewXsltCompiler();
	$saxCompiler.BaseUri = $PSScriptRoot;
	Write-Verbose 'Compiling XSLT...';
	try {
		$saxExecutable = $saxCompiler.Compile( ( Join-Path -Path $PSScriptRoot -ChildPath 'Optimize-PlainXML.xslt' ) );
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
	if ( $PSCmdlet.ShouldProcess( $Path, "Optimize Open Office XML files" ) ) {
		Get-ChildItem -Path $Path -Recurse -Filter '*.xml' | Where-Object { $_.Length -gt 0 } | ForEach-Object {
			$sourceFile = $_;
			$sourceXMLFileStream = [System.IO.File]::OpenRead( $sourceFile.FullName );
			try {
				$saxTransform.SetInputStream( $sourceXMLFileStream, $DTDPath );

				$TempXMLFileName = [System.IO.Path]::GetTempFileName();
				try {
					$saxWriter = $saxProcessor.NewSerializer();
					$saxWriter.SetOutputFile( $TempXMLFileName );
					$saxTransform.Run( $saxWriter );
					$saxWriter.Close();
					Move-Item -Path $TempXMLFileName -Destination ( $sourceFile.FullName ) -Force `
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
}
