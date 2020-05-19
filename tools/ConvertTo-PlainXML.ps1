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

	$DtdPath = ( Resolve-Path -Path 'dtd/officedocument/1_0/' ).Path;
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
					if ( $PSCmdlet.ShouldProcess( $TempXMLFolder, "Format all xml files in Open Office document plain XML directory" ) ) {
						$saxTransform = $saxExecutable.Load();
						$saxTransform.SchemaValidationMode = [Saxon.Api.SchemaValidationMode]::None;

						$saxTransform.InitialMode = New-Object Saxon.Api.QName -ArgumentList `
							'http://github.com/test-st-petersburg/DocTemplates/tools/xslt', 'outline';

						[System.Uri] $BaseUri = $DestinationTempPathForFile + [System.IO.Path]::DirectorySeparatorChar;
						# TODO: Решить проблему с использованием [System.Uri]::EscapeUriString
						$BaseUri = $BaseUri.AbsoluteUri;
						Write-Verbose "Source base URI: $( $BaseUri )";

						$FormatterTempXMLFolder = New-Item -ItemType Directory `
							-Path ( [System.IO.Path]::GetTempPath() ) `
							-Name ( [System.IO.Path]::GetRandomFileName() );
						try {
							$saxTransform.BaseOutputURI = ( [System.Uri] ( $FormatterTempXMLFolder.FullName + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri;
							Write-Verbose "Destination base URI: $( $saxTransform.BaseOutputURI )";

							$ManifestPath = ( Resolve-Path -Path ( Join-Path -Path $DestinationTempPathForFile -ChildPath 'META-INF/manifest.xml' ) ).Path;
							# TODO: Решить проблему с использованием [System.Uri]::EscapeUriString
							[System.Uri] $ManifestUri = $ManifestPath;
							$saxTransform.SetInputStream(
								( New-Object System.IO.FileStream -ArgumentList $ManifestPath, 'Open' ),
								$ManifestUri );
							$saxTransform.Run( ( New-Object Saxon.Api.NullDestination ) );

							Write-Verbose 'Transformation done';

							Get-ChildItem -Path $FormatterTempXMLFolder | Copy-Item -Destination $DestinationTempPathForFile -Recurse -Force `
								-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
								-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
						}
						finally {
							Remove-Item -Path $FormatterTempXMLFolder -Recurse `
								-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
								-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
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
