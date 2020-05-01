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

	$saxTransform = . ( Join-Path -Path $PSScriptRoot -ChildPath 'Get-XSLTTransform.ps1' ) `
		-LiteralPath ( Join-Path -Path $PSScriptRoot -ChildPath 'Optimize-PlainXML.xslt' ) `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
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
					$saxWriter = New-Object Saxon.Api.Serializer;
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
