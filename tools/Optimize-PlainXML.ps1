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
		'tools/xslt/optimizer/OOOptimizer.xslt', `
		'tools/xslt/OODocumentProcessor/oo-writer.xslt', `
		'tools/xslt/OODocumentProcessor/oo-merger.xslt' `
		-LiteralPath ( Join-Path -Path $PSScriptRoot -ChildPath 'xslt/Transform-PlainXML.xslt' ) `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
	$DTDPath = ( Resolve-Path -Path 'dtd/officedocument/1_0/' ).Path;
}
process {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	if ( $PSCmdlet.ShouldProcess( $Path, "Optimize Open Office XML files" ) ) {
		$saxTransform = $saxExecutable.Load();
		$saxTransform.SchemaValidationMode = [Saxon.Api.SchemaValidationMode]::Preserve;

		$saxTransform.InitialMode = New-Object Saxon.Api.QName -ArgumentList `
			'http://github.com/test-st-petersburg/DocTemplates/tools/xslt',	'optimize';

		[System.Uri] $BaseUri = ( Resolve-Path -Path $Path ).Path + [System.IO.Path]::DirectorySeparatorChar;
		# TODO: Решить проблему с использованием [System.Uri]::EscapeUriString
		$BaseUri = $BaseUri.AbsoluteUri;
		Write-Verbose "Source base URI: $( $BaseUri )";

		$FormatterTempXMLFolder = New-Item -ItemType Directory `
			-Path ( [System.IO.Path]::GetTempPath() ) `
			-Name ( [System.IO.Path]::GetRandomFileName() );
		try {
			$saxTransform.BaseOutputURI = ( [System.Uri] ( $FormatterTempXMLFolder.FullName + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri;
			Write-Verbose "Destination base URI: $( $saxTransform.BaseOutputURI )";

			$ManifestPath = ( Resolve-Path -Path ( Join-Path -Path $Path -ChildPath 'META-INF/manifest.xml' ) ).Path;
			# TODO: Решить проблему с использованием [System.Uri]::EscapeUriString
			[System.Uri] $ManifestUri = $ManifestPath;
			$saxTransform.SetInputStream(
				( New-Object System.IO.FileStream -ArgumentList $ManifestPath, 'Open' ),
				$ManifestUri );
			$saxTransform.Run( ( New-Object Saxon.Api.NullDestination ) );

			Write-Verbose 'Transformation done';

			Get-ChildItem -Path $FormatterTempXMLFolder | Copy-Item -Destination $Path -Recurse -Force `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		}
		finally {
			Remove-Item -Path $FormatterTempXMLFolder -Recurse `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};
	};
}
