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

	$saxExecutable = . ( Join-Path -Path $PSScriptRoot -ChildPath 'Get-XSLTExecutable.ps1' ) `
		-PackagesPath ( Join-Path -Path $PSScriptRoot -ChildPath 'xslt' ) `
		-LiteralPath ( Join-Path -Path $PSScriptRoot -ChildPath 'Transform-OpenOfficeDocument.xslt' ) `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
	$DTDPath = ( Resolve-Path -Path 'dtd/officedocument/1_0/' ).Path;
}
process {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	if ( $PSCmdlet.ShouldProcess( $Path, "Optimize Open Office XML files" ) ) {
		$saxTransform = $saxExecutable.Load30();
		$saxTransform.SchemaValidationMode = [Saxon.Api.SchemaValidationMode]::Preserve;

		[System.Uri] $BaseUri = ( [System.Uri] ( $Path + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri;
		$XSLTParams = New-Object 'System.Collections.Generic.Dictionary`2[Saxon.Api.QName,Saxon.Api.XdmValue]';
		$XSLTParams.Add( 'base-uri', ( New-Object Saxon.Api.XdmAtomicValue -ArgumentList ( $BaseUri ) ) );
		$saxTransform.SetStylesheetParameters( $XSLTParams );
		Write-Verbose "Source base URI: $( $BaseUri )";

		$TempXMLFolder = New-Item -ItemType Directory `
			-Path ( [System.IO.Path]::GetTempPath() ) `
			-Name ( [System.IO.Path]::GetRandomFileName() );
		try {
			$saxTransform.BaseOutputURI = ( [System.Uri] ( $TempXMLFolder.FullName + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri;
			Write-Verbose "Destination base URI: $( $saxTransform.BaseOutputURI )";
			$null = $saxTransform.CallTemplate( 'optimize' );
			Write-Verbose 'Transformation done';

			Get-ChildItem -Path $TempXMLFolder | Copy-Item -Destination $Path -Recurse -Force `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		}
		finally {
			Remove-Item -Path $TempXMLFolder -Recurse `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};
	};
}
