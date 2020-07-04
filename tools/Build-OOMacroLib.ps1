<#
	.SYNOPSIS
		Создаёт каталог библиотека макросов office файлы из папки с "исходными" файлами
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	# путь к папке с исходными файлами
	[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
	[System.String]
	$Path,

	# путь к папке, в которой будет создана библиотека макросов Open Office
	[Parameter( Mandatory = $true, Position = 1, ValueFromPipeline = $false )]
	[System.String]
	$DestinationPath,

	# перезаписать существующие каталоги и файлы
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

	$LibraryName = Split-Path -Path $Path -Leaf;

	if ( $PSCmdlet.ShouldProcess( $LibraryName, "Create Open Office macro library from source directory" ) ) {

		$DestinationLibraryPath = Join-Path -Path $DestinationPath -ChildPath $LibraryName;

		if ( Test-Path -Path $DestinationLibraryPath ) {
			if ( -not $Force ) {
				Write-Error -Message "Destination library path ""$DestinationLibraryPath"" exists.";
			};
			Remove-Item -Path $DestinationLibraryPath -Recurse -Force `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};
		New-Item -Path $DestinationLibraryPath -ItemType Directory `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true ) `
		| Out-Null;

		$saxTransform = $saxExecutable.Load();
		$saxTransform.SchemaValidationMode = [Saxon.Api.SchemaValidationMode]::None;

		# $saxTransform.InitialMode = New-Object Saxon.Api.QName -ArgumentList `
		# 	'http://github.com/test-st-petersburg/DocTemplates/tools/xslt',	'before-pack';

		# $saxTransform.SetParameter(
		# 	( New-Object Saxon.Api.QName -ArgumentList 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt', 'version' ),
		# 	( New-Object Saxon.Api.XdmAtomicValue -ArgumentList $Version )
		# )

		# TODO: Решить проблему с использованием [System.Uri]::EscapeUriString
		[System.Uri] $BaseUri = ( [System.Uri] ( $Path + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri;
		Write-Verbose "Source base URI: $( $BaseUri )";

		# TODO: Решить проблему с использованием [System.Uri]::EscapeUriString
		[System.Uri] $BaseOutputURI = ( [System.Uri] ( $DestinationLibraryPath + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri;
		$saxTransform.BaseOutputURI = $BaseOutputURI;
		Write-Verbose "Destination base URI: $( $saxTransform.BaseOutputURI )";

		# $saxTransform.SetInputStream(
		# 	( New-Object System.IO.FileStream -ArgumentList $ManifestPath, 'Open' ),
		# 	$ManifestUri );
		# $saxTransform.Run( ( New-Object Saxon.Api.NullDestination ) );

		Write-Verbose "Macroses library $LibraryName is ready in ""$DestinationLibraryPath"".";
	};
};
