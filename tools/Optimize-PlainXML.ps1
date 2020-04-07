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

	Add-Type -Path ( Join-Path -Path ( Split-Path -Path ( ( Get-Package -Name 'Saxon-HE' ).Source ) -Parent ) -ChildPath 'lib\net40\saxon9he-api.dll' ) `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

	$saxProcessor = New-Object Saxon.Api.Processor;
	$saxCompiler = $saxProcessor.NewXsltCompiler();
	$saxCompiler.BaseUri = $PSScriptRoot;
	Write-Verbose 'Compiling XSLT...';
	$saxExecutable = $saxCompiler.Compile( ( Join-Path -Path $PSScriptRoot -ChildPath 'Optimize-PlainXML.xslt' ) );
	$saxTransform = $saxExecutable.Load();
	Write-Verbose 'XSLT loaded.';
	$saxTransform.SchemaValidationMode = [Saxon.Api.SchemaValidationMode]::Preserve;
	# $saxTransform.RecoveryPolicy = [Saxon.Api.RecoveryPolicy]::DoNotRecover;

	$DTDPath = ( Resolve-Path -Path 'dtd/officedocument/1_0/' ).Path;
}
process {
	if ( $PSCmdlet.ShouldProcess( $FilePath, "Optimize Open Office content.xml" ) ) {
		$sourceFile = Get-Item -Path $FilePath;
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
}
