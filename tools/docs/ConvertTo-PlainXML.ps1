﻿# Copyright © 2020 Sergei S. Betke

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

begin
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	$saxExecutable = & $PSScriptRoot/../xslt/Get-XSLTExecutable.ps1 `
		-PackagePath ( `
			'xslt/system/uri.xslt', `
			'xslt/formatter/basic.xslt', 'xslt/formatter/OO.xslt', `
			'xslt/optimizer/OOOptimizer.xslt', `
			'xslt/OODocumentProcessor/oo-writer.xslt', `
			'xslt/OODocumentProcessor/oo-macrolib.xslt', `
			'xslt/OODocumentProcessor/oo-merger.xslt', `
			'xslt/OODocumentProcessor/oo-preprocessor.xslt', `
			'xslt/OODocumentProcessor/oo-document.xslt' ) `
		-Path 'xslt/Transform-PlainXML.xslt' `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true );
}
process
{
	if ( $PSCmdlet.ShouldProcess( $FilePath, "Convert Open Office document to plain XML directory" ) )
	{
		$DestinationDirName = ( Get-Item $FilePath ).Name;
		$DestinationPathForFile = Join-Path -Path $DestinationPath -ChildPath $DestinationDirName;
		if ( Test-Path -Path $DestinationPathForFile )
		{
			Remove-Item -Path $DestinationPathForFile -Recurse `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
		};
		if ( -Not ( Test-Path -Path $DestinationPath ) )
		{
			$null = New-Item -Path $DestinationPath -ItemType Directory `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
		};
		$TempZIPFileName = Join-Path `
			-Path ( [System.IO.Path]::GetTempPath() ) `
			-ChildPath ( [System.IO.Path]::GetRandomFileName() );
		$TempZIPFileName = $TempZIPFileName + '.zip';
		Copy-Item -Path $FilePath -Destination $TempZIPFileName `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
		try
		{

			$TempXMLFolder = Join-Path `
				-Path ( [System.IO.Path]::GetTempPath() ) `
				-ChildPath ( [System.IO.Path]::GetRandomFileName() );
			$DestinationTempPathForFile = Join-Path -Path $TempXMLFolder -ChildPath $DestinationDirName;
			Expand-Archive -Path $TempZIPFileName -DestinationPath $DestinationTempPathForFile `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
			try
			{
				if ( $Indented )
				{
					if ( $PSCmdlet.ShouldProcess( $TempXMLFolder, "Format all xml files in Open Office document plain XML directory" ) )
					{

						$saxTransform = $saxExecutable.Load30();

						[System.String] $BaseUri = ( [System.Uri] ( $DestinationTempPathForFile + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri.ToString().Replace(' ', '%20');
						Write-Verbose "Source base URI: $( $BaseUri )";

						$FormatterTempXMLFolder = New-Item -ItemType Directory `
							-Path ( [System.IO.Path]::GetTempPath() ) `
							-Name ( [System.IO.Path]::GetRandomFileName() );
						try
						{
							$saxTransform.BaseOutputURI = (
								[System.Uri] ( $FormatterTempXMLFolder.FullName + [System.IO.Path]::DirectorySeparatorChar )
							).AbsoluteUri.ToString().Replace(' ', '%20');
							Write-Verbose "Destination base URI: $( $saxTransform.BaseOutputURI )";

							$Params = [System.Collections.Generic.Dictionary[[Saxon.Api.QName], [Saxon.Api.XdmValue]]]::new();
							$Params.Add(
								[Saxon.Api.QName]::new( 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
									'source-directory' ),
								[Saxon.Api.XdmAtomicValue]::new( $BaseUri )
							);
							$saxTransform.SetInitialTemplateParameters( $Params, $false );

							$null = $saxTransform.CallTemplate(
								[Saxon.Api.QName]::new( 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
									'prepare-after-unpacking' )
							);

							Write-Verbose 'Transformation done';

							Get-ChildItem -Path $FormatterTempXMLFolder | Copy-Item -Destination $DestinationTempPathForFile -Recurse -Force `
								-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
								-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
						}
						finally
						{
							Remove-Item -Path $FormatterTempXMLFolder -Recurse `
								-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
								-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
						};

					};
				};
				Copy-Item -Path $DestinationTempPathForFile -Destination $DestinationPath -Recurse `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
			}
			finally
			{
				Remove-Item -Path $TempXMLFolder -Recurse `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
			};
		}
		finally
		{
			Remove-Item -Path $TempZIPFileName `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
		};
	};
}
