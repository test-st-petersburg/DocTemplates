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

	Push-Location -Path $PSScriptRoot;
	$saxExecutable = .\Get-XSLTExecutable.ps1 `
		-PackagePath 'xslt/formatter/basic.xslt', 'xslt/formatter/OO.xslt', `
		'xslt/optimizer/OOOptimizer.xslt', `
		'xslt/OODocumentProcessor/oo-writer.xslt', `
		'xslt/OODocumentProcessor/oo-merger.xslt', `
		'xslt/OODocumentProcessor/oo-preprocessor.xslt' `
		-Path 'xslt/Transform-PlainXML.xslt' `
		-DtdPath 'dtd/officedocument/1_0/' `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
	Pop-Location;
}
process {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	if ( $PSCmdlet.ShouldProcess( $Path, "Optimize Open Office XML files" ) ) {
		$saxTransform = $saxExecutable.Load();
		$saxTransform.SchemaValidationMode = [Saxon.Api.SchemaValidationMode]::None;

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
