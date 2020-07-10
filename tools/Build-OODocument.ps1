<#
	.SYNOPSIS
		Создаёт open office файлы из папки с xml файлами
#>

#Requires -Version 5.0
#Requires -Modules 7Zip4Powershell

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	# путь к папке с xml файлами
	[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
	[System.String]
	$Path,

	# путь к папке, в которой будет создан файл Open Office
	[Parameter( Mandatory = $true, Position = 1, ValueFromPipeline = $false )]
	[System.String]
	$DestinationPath,

	# путь к папке, в которой будет каталог с препроцессированными XML файлами
	# перед сборкой документа либо шаблона
	[Parameter( Mandatory = $false, ValueFromPipeline = $false )]
	[System.String]
	$TempPath = [System.IO.Path]::GetTempPath(),

	# версия файла (для указания в свойствах файла Open Office)
	[Parameter( Mandatory = $false, ValueFromPipeline = $false )]
	[System.String]
	$Version,

	# перезаписать существующий файл
	[Parameter()]
	[Switch]
	$Force
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

	[System.String]	$FileName = ( Split-Path -Path $Path -Leaf );

	if ( $PSCmdlet.ShouldProcess( $Path, "Create Open Office document from plain XML directory" ) ) {

		$PreprocessedXMLPath = Join-Path -Path $TempPath -ChildPath $FileName;

		if ( Test-Path -Path $PreprocessedXMLPath ) {
			if ( -not $Force ) {
				Write-Error -Message "Preprocessed XML files path ""$PreprocessedXMLPath"" exists.";
			};
			Remove-Item -Path $PreprocessedXMLPath -Recurse -Force `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};

		$saxTransform = $saxExecutable.Load30();

		[System.String] $BaseUri = ( [System.Uri] ( $PreprocessedXMLPath + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri.ToString().Replace(' ', '%20');
		Write-Verbose "Source base URI: $( $BaseUri )";

		Copy-Item -Path $Path -Destination $PreprocessedXMLPath -Recurse `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

		$TempXMLFolder = New-Item -ItemType Directory `
			-Path ( [System.IO.Path]::GetTempPath() ) `
			-Name ( [System.IO.Path]::GetRandomFileName() );
		$TempXMLPath = $TempXMLFolder.FullName;
		try {

			$saxTransform.BaseOutputURI = (
				[System.Uri] ( $TempXMLPath + [System.IO.Path]::DirectorySeparatorChar )
			).AbsoluteUri.ToString().Replace(' ', '%20');
			Write-Verbose "Destination base URI: $( $saxTransform.BaseOutputURI )";

			$Params = New-Object 'System.Collections.Generic.Dictionary[ [Saxon.Api.QName], [Saxon.Api.XdmValue] ]';
			$Params.Add(
				( New-Object Saxon.Api.QName -ArgumentList 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt',
					'source-directory' ),
				( New-Object Saxon.Api.XdmAtomicValue -ArgumentList $BaseUri )
			)
			if ( $Version ) {
				$Params.Add(
					( New-Object Saxon.Api.QName -ArgumentList 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt',
						'version' ),
					( New-Object Saxon.Api.XdmAtomicValue -ArgumentList $Version )
				)
			};
			$saxTransform.SetInitialTemplateParameters( $Params, $false );

			if ( $PSCmdlet.ShouldProcess( $PreprocessedXMLPath, "Preprocess Open Office XML" ) ) {
				$null = $saxTransform.CallTemplate(
					( New-Object Saxon.Api.QName -ArgumentList 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt',
						'preprocess' )
				);
				Get-ChildItem -Path $TempXMLPath | Copy-Item -Destination $PreprocessedXMLPath -Recurse -Force `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
				Write-Verbose 'Preprocessing done';
				Get-ChildItem -Path $TempXMLFolder | Remove-Item -Recurse -Force;
			};

			Get-ChildItem -Path $PreprocessedXMLPath | Copy-Item -Destination $TempXMLPath -Recurse `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

			if ( $PSCmdlet.ShouldProcess( $PreprocessedXMLPath, "Unindent Open Office XML" ) ) {
				$null = $saxTransform.CallTemplate(
					( New-Object Saxon.Api.QName -ArgumentList 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt',
						'prepare-for-packing' )
				);
				Write-Verbose 'Transformation done';
			};

			$TempZIPFileName = (
				Join-Path `
					-Path ( [System.IO.Path]::GetTempPath() ) `
					-ChildPath ( [System.IO.Path]::GetRandomFileName() ) `
			) + '.zip';
			try {
				# по требованиям Open Office первым добавляем **без сжатия** файл mimetype
				Compress-7Zip -ArchiveFileName $TempZIPFileName `
					-Path $TempXMLPath `
					-Filter 'mimetype' `
					-Format Zip `
					-CompressionLevel None `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
					-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
				Get-ChildItem -Path $TempXMLPath -File -Recurse `
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
					Remove-Item -Path $TempZIPFileName `
						-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
						-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
				};
			};

		}
		finally {
			Remove-Item -Path $TempXMLPath -Recurse `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};

	};
};
