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

	$DTDPath = ( Resolve-Path -Path 'dtd/officedocument/1_0/' ).Path;
	$saxExecutable = . ( Join-Path -Path $PSScriptRoot -ChildPath 'Get-XSLTExecutable.ps1' ) `
		-PackagePath 'tools/xslt/formatter/basic.xslt', 'tools/xslt/formatter/OO.xslt', `
		'tools/xslt/optimizer/OOOptimizer.xslt', `
		'tools/xslt/OODocumentProcessor/oo-writer.xslt', `
		'tools/xslt/OODocumentProcessor/oo-merger.xslt' `
		-LiteralPath ( Join-Path -Path $PSScriptRoot -ChildPath 'xslt/Transform-PlainXML.xslt' ) `
		-DtdPath $DtdPath `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
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
			if ( $PSCmdlet.ShouldProcess( $TempXMLFolder, "Unindent all xml source files before build Open Office file" ) ) {
				$saxTransform = $saxExecutable.Load();
				$saxTransform.SchemaValidationMode = [Saxon.Api.SchemaValidationMode]::None;

				$saxTransform.InitialMode = New-Object Saxon.Api.QName -ArgumentList `
					'http://github.com/test-st-petersburg/DocTemplates/tools/xslt',	'before-pack';

				[System.Uri] $BaseUri = $TempXMLFolder + [System.IO.Path]::DirectorySeparatorChar;
				# TODO: Решить проблему с использованием [System.Uri]::EscapeUriString
				$BaseUri = $BaseUri.AbsoluteUri;
				Write-Verbose "Source base URI: $( $BaseUri )";

				$FormatterTempXMLFolder = New-Item -ItemType Directory `
					-Path ( [System.IO.Path]::GetTempPath() ) `
					-Name ( [System.IO.Path]::GetRandomFileName() );
				try {
					$saxTransform.BaseOutputURI = ( [System.Uri] ( $FormatterTempXMLFolder.FullName + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri;
					Write-Verbose "Destination base URI: $( $saxTransform.BaseOutputURI )";

					$ManifestPath = ( Resolve-Path -Path ( Join-Path -Path $TempXMLFolder -ChildPath 'META-INF/manifest.xml' ) ).Path;
					# TODO: Решить проблему с использованием [System.Uri]::EscapeUriString
					[System.Uri] $ManifestUri = $ManifestPath;
					$saxTransform.SetInputStream(
						( New-Object System.IO.FileStream -ArgumentList $ManifestPath, 'Open' ),
						$ManifestUri );
					$saxTransform.Run( ( New-Object Saxon.Api.NullDestination ) );

					Write-Verbose 'Transformation done';

					Get-ChildItem -Path $FormatterTempXMLFolder | Copy-Item -Destination $TempXMLFolder -Recurse -Force `
						-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
						-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
				}
				finally {
					Remove-Item -Path $FormatterTempXMLFolder -Recurse `
						-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
						-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
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
