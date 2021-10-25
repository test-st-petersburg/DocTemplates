﻿# Copyright © 2020 Sergei S. Betke

<#
	.SYNOPSIS
		Создаёт open office файлы из папки с xml файлами
#>

#Requires -Version 5.0
#Requires -Modules 7Zip4Powershell

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	# путь к папке с xml файлами
	[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $false )]
	[Alias( 'Path' )]
	[Alias( 'PSPath' )]
	[ValidateNotNullOrEmpty()]
	[System.String]
	$LiteralPath,

	# путь к папке, в которой будет создан файл Open Office
	[Parameter( Mandatory = $true, Position = 1, ValueFromPipeline = $false )]
	[System.String]
	$Destination,

	# путь к папке, в которой будет каталог с препроцессированными XML файлами
	# перед сборкой документа либо шаблона
	[Parameter( Mandatory = $false, ValueFromPipeline = $false )]
	[ValidateNotNullOrEmpty()]
	[System.String]
	$PreprocessedPath,

	# путь к папке с библиотеками макросов (для внедрения в шаблоны)
	[Parameter( Mandatory = $false, ValueFromPipeline = $false )]
	[ValidateNotNullOrEmpty()]
	[System.String]
	$LibrariesPath,

	# путь к папке с шаблонами (для внедрения в документы)
	[Parameter( Mandatory = $false, ValueFromPipeline = $false )]
	[ValidateNotNullOrEmpty()]
	[System.String]
	$TemplatesPath,

	# версия файла (для указания в свойствах файла Open Office)
	[Parameter( Mandatory = $false, ValueFromPipeline = $false )]
	[System.String]
	$Version,

	# перезаписать существующий файл
	[Parameter()]
	[Switch]
	$Force
)

begin
{
	Set-StrictMode -Version Latest;
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	$saxExecutable = & $PSScriptRoot/../xslt/Get-XSLTExecutable.ps1 `
		-PackagePath ( `
			'xslt/system/uri.xslt', `
			'xslt/formatter/basic.xslt', 'xslt/formatter/OO.xslt', `
			'xslt/optimizer/OOOptimizer.xslt', `
			'xslt/OODocumentProcessor/oo-writer.xslt', `
			'xslt/OODocumentProcessor/oo-merger.xslt', `
			'xslt/OODocumentProcessor/oo-macrolib.xslt', `
			'xslt/OODocumentProcessor/oo-preprocessor.xslt', `
			'xslt/OODocumentProcessor/oo-document.xslt' ) `
		-Path 'xslt/Transform-PlainXML.xslt' `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true );
}
process
{
	Set-StrictMode -Version Latest;
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	[System.String]	$FileName = ( Split-Path -Path $Destination -Leaf );

	if ( $PSCmdlet.ShouldProcess( $LiteralPath, "Create Open Office document from plain XML directory" ) )
	{

		#region создание каталога назначения
		[System.String] $DestinationPath = ( Split-Path -Path $Destination -Parent );
		if ( -not ( Test-Path -Path $DestinationPath ) )
		{
			New-Item -Path $DestinationPath -ItemType Directory `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true ) `
			| Out-Null;
		};
		#endregion

		#region подготовка препроцессирования

		if ( $PSCmdlet.MyInvocation.BoundParameters.ContainsKey( 'PreprocessedPath' ) )
		{
			[System.String] $PreprocessedXMLPath = $PreprocessedPath;
		}
		else
		{
			[System.String] $PreprocessedXMLPath = Join-Path `
				-Path ( Join-Path -Path ( [System.IO.Path]::GetTempPath() ) -ChildPath ( [System.IO.Path]::GetRandomFileName() ) ) `
				-ChildPath $FileName;
		};

		if ( Test-Path -Path $PreprocessedXMLPath )
		{
			if ( -not $Force )
			{
				Write-Error -Message "Preprocessed XML files path ""$PreprocessedXMLPath"" exists.";
			};
			Remove-Item -Path $PreprocessedXMLPath -Recurse -Force `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
		};
		# TODO: workaround for https://saxonica.plan.io/issues/4644
		'', 'Basic', 'Configurations2'  `
		| ForEach-Object {
			$null = New-Item -Path ( Join-Path -Path $PreprocessedXMLPath -ChildPath $_ ) -ItemType Directory -Force `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
		};

		$saxTransform = $saxExecutable.Load30();

		[System.String] $BaseUri = ( [System.Uri] ( $LiteralPath + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri.ToString().Replace(' ', '%20');
		Write-Verbose "Source base URI: $( $BaseUri )";

		#endregion

		$TempXMLFolder = New-Item -ItemType Directory `
			-Path ( [System.IO.Path]::GetTempPath() ) `
			-Name ( [System.IO.Path]::GetRandomFileName() );
		$TempXMLPath = $TempXMLFolder.FullName;
		try
		{

			#region препроцессирование XML файлов

			$saxTransform.BaseOutputURI = (
				[System.Uri] ( $TempXMLPath + [System.IO.Path]::DirectorySeparatorChar )
			).AbsoluteUri.ToString().Replace(' ', '%20');
			Write-Verbose "Destination base URI: $( $saxTransform.BaseOutputURI )";

			$StylesheetParams = [System.Collections.Generic.Dictionary[[Saxon.Api.QName], [Saxon.Api.XdmValue]]]::new();
			if ( $LibrariesPath )
			{
				[System.String] $LibrariesUri = ( [System.Uri] ( $LibrariesPath + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri.ToString().Replace(' ', '%20');
				Write-Verbose "Used libraries URI: $LibrariesUri";
				$StylesheetParams.Add(
					[Saxon.Api.QName]::new( 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
						'linked-libraries-uri' ),
					[Saxon.Api.XdmAtomicValue]::new( [System.Uri] ( $LibrariesUri ) )
				);
			};
			if ( $TemplatesPath )
			{
				[System.String] $TemplatesUri = ( [System.Uri] ( $TemplatesPath + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri.ToString().Replace(' ', '%20');
				Write-Verbose "Templates URI: $TemplatesUri";
				$StylesheetParams.Add(
					[Saxon.Api.QName]::new( 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
						'linked-templates-uri' ),
					[Saxon.Api.XdmAtomicValue]::new( [System.Uri] ( $TemplatesUri ) )
				);
			};
			$saxTransform.SetStylesheetParameters( $StylesheetParams );

			$Params = [System.Collections.Generic.Dictionary[[Saxon.Api.QName], [Saxon.Api.XdmValue]]]::new();
			$Params.Add(
				[Saxon.Api.QName]::new( 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
					'source-directory' ),
				[Saxon.Api.XdmAtomicValue]::new( $BaseUri )
			);
			if ( $Version )
			{
				$Params.Add(
					[Saxon.Api.QName]::new( 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
						'version' ),
					[Saxon.Api.XdmAtomicValue]::new( $Version )
				);
			};
			$saxTransform.SetInitialTemplateParameters( $Params, $false );

			if ( $PSCmdlet.ShouldProcess( $LiteralPath, "Preprocess Open Office XML" ) )
			{
				$null = $saxTransform.CallTemplate(
					[Saxon.Api.QName]::new( 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
						'preprocess' )
				);
				Get-ChildItem -Path $TempXMLPath | Copy-Item -Destination $PreprocessedXMLPath -Recurse -Force `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
				Write-Verbose 'Preprocessing done';
				Get-ChildItem -Path $TempXMLFolder | Remove-Item -Recurse -Force;
			};

			#endregion

			#region копирование не XML файлов

			[System.String] $BinaryFilesManifest = Join-Path -Path $PreprocessedXMLPath -ChildPath 'META-INF/manifest.binary.xml';
			Select-Xml -LiteralPath $BinaryFilesManifest `
				-XPath 'manifest:manifest/manifest:file-entry' `
				-Namespace @{ 'manifest' = 'urn:oasis:names:tc:opendocument:xmlns:manifest:1.0'; } `
			| Select-Object -ExpandProperty Node `
			| ForEach-Object {
				[System.String] $SourceBinFilePath = ( Join-Path -Path ( ( [System.Uri]( $_.base ) ).LocalPath ) -ChildPath ( $_.'full-path' ) );
				[System.String] $DestinationBinFilePath = ( Join-Path -Path $PreprocessedXMLPath -ChildPath ( $_.'full-path' ) );
				[System.String] $DestinationBinFileDirectory = ( Split-Path -Path $DestinationBinFilePath -Parent );
				if ( -not ( Test-Path -Path $DestinationBinFileDirectory -PathType Container ) )
				{
					$null = New-Item -Path $DestinationBinFileDirectory -ItemType Directory -Force;
				};
				Copy-Item -LiteralPath $SourceBinFilePath -Destination $DestinationBinFilePath -Force `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
			};
			if ( Test-Path -Path $BinaryFilesManifest )
			{
				Remove-Item -Path $BinaryFilesManifest `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
			};

			#endregion

			Get-ChildItem -Path $PreprocessedXMLPath | Copy-Item -Destination $TempXMLPath -Recurse `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );

			#region удаление форматирования из XML файлов

			if ( $PSCmdlet.ShouldProcess( $PreprocessedXMLPath, "Unindent Open Office XML" ) )
			{

				[System.String] $PreprocessedUri = (
					[System.Uri] ( $PreprocessedXMLPath + [System.IO.Path]::DirectorySeparatorChar )
				).AbsoluteUri.ToString().Replace(' ', '%20');

				$Params = [System.Collections.Generic.Dictionary[[Saxon.Api.QName], [Saxon.Api.XdmValue]]]::new();
				$Params.Add(
					[Saxon.Api.QName]::new( 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
						'source-directory' ),
					[Saxon.Api.XdmAtomicValue]::new( $PreprocessedUri )
				);
				if ( $Version )
				{
					$Params.Add(
						[Saxon.Api.QName]::new( 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
							'version' ),
						[Saxon.Api.XdmAtomicValue]::new( $Version )
					);
				};
				$saxTransform.SetInitialTemplateParameters( $Params, $false );
				$null = $saxTransform.CallTemplate(
					[Saxon.Api.QName]::new( 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
						'prepare-for-packing' )
				);

				Write-Verbose 'Transformation done';
			};

			#endregion

			#region архивирование файлов (сборка документов, их шаблонов)

			$TempZIPFileName = (
				Join-Path `
					-Path ( [System.IO.Path]::GetTempPath() ) `
					-ChildPath ( [System.IO.Path]::GetRandomFileName() ) `
			) + '.zip';
			try
			{
				# по требованиям Open Office первым добавляем **без сжатия** файл mimetype
				Compress-7Zip -ArchiveFileName $TempZIPFileName `
					-Path $TempXMLPath `
					-Filter 'mimetype' `
					-Format Zip `
					-CompressionLevel None `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
				Get-ChildItem -Path $TempXMLPath -File -Recurse `
					-Exclude 'mimetype' `
				| Compress-7Zip -ArchiveFileName $TempZIPFileName -Append `
					-Format Zip `
					-CompressionLevel Normal -CompressionMethod Deflate `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
				Move-Item -Path $TempZIPFileName `
					-Destination $Destination `
					-Force:( $PSCmdlet.MyInvocation.BoundParameters['Force'] -eq $true ) `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
			}
			finally
			{
				if ( Test-Path -Path $TempZIPFileName )
				{
					Remove-Item -Path $TempZIPFileName;
				};
			};

			#endregion

		}
		finally
		{
			Remove-Item -Path $TempXMLPath -Recurse;
		};

	};
};
