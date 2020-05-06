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
		-PackagePath 'tools/xslt/formatter/basic.xslt', 'tools/xslt/formatter/OO.xslt', `
		'tools/xslt/OODocumentProcessor/main.xslt' `
		-LiteralPath ( Join-Path -Path $PSScriptRoot -ChildPath 'xslt/optimizer/Optimize-PlainXML.xslt' ) `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
	$DTDPath = ( Resolve-Path -Path 'dtd/officedocument/1_0/' ).Path;
}
process {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	if ( $PSCmdlet.ShouldProcess( $Path, "Optimize Open Office XML files" ) ) {
		$saxTransform = $saxExecutable.Load30();
		$saxTransform.SchemaValidationMode = [Saxon.Api.SchemaValidationMode]::Preserve;

		[System.Uri] $BaseUri = ( Resolve-Path -Path $Path ).Path + [System.IO.Path]::DirectorySeparatorChar;
		# TODO: Решить проблему с использованием [System.Uri]::EscapeUriString
		$BaseUri = $BaseUri.AbsoluteUri;
		Write-Verbose "Source base URI: $( $BaseUri )";

		$TempXMLFolder = New-Item -ItemType Directory `
			-Path ( [System.IO.Path]::GetTempPath() ) `
			-Name ( [System.IO.Path]::GetRandomFileName() );
		try {
			$saxTransform.BaseOutputURI = ( [System.Uri] ( $TempXMLFolder.FullName + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri;
			Write-Verbose "Destination base URI: $( $saxTransform.BaseOutputURI )";

			$XSLTParams = New-Object 'System.Collections.Generic.Dictionary`2[Saxon.Api.QName,Saxon.Api.XdmValue]';
			$XSLTParams.Add(
				( New-Object Saxon.Api.QName -ArgumentList `
						'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
					'document-folder-uri' ),
				( New-Object Saxon.Api.XdmAtomicValue -ArgumentList ( $BaseUri ) ) 	);
			$saxTransform.SetInitialTemplateParameters( $XSLTParams, $true );

			$null = $saxTransform.CallTemplate( ( New-Object Saxon.Api.QName -ArgumentList `
						'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
					'process' ) );
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
