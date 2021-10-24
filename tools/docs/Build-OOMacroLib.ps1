# Copyright © 2020 Sergei S. Betke

<#
	.SYNOPSIS
		Создаёт каталог библиотеки макросов из папки с "исходными" файлами
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	# путь к папке с исходными файлами
	[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $false )]
	[Alias( 'Path' )]
	[Alias( 'PSPath' )]
	[ValidateNotNullOrEmpty()]
	[System.String]
	$LiteralPath,

	# путь к папке, в которой будет создана библиотека макросов Open Office
	[Parameter( Mandatory = $true, Position = 1, ValueFromPipeline = $false )]
	[System.String]
	$Destination,

	# имя библиотеки
	[Parameter( Mandatory = $true, Position = 2, ValueFromPipeline = $false )]
	[System.String]
	$Name,

	# перезаписать существующие каталоги и файлы
	[Parameter()]
	[Switch]
	$Force
)

begin
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	Set-StrictMode -Version Latest;

	$saxExecutable = & $PSScriptRoot/../xslt/Get-XSLTExecutable.ps1 `
		-PackagePath ( `
			'xslt/system/uri.xslt', `
			'xslt/system/fix-saxon.xslt', `
			'xslt/formatter/basic.xslt', 'xslt/formatter/OO.xslt', `
			'xslt/OODocumentProcessor/oo-writer.xslt', `
			'xslt/OODocumentProcessor/oo-macrolib.xslt' ) `
		-Path 'xslt/Build-OOMacroLib.xslt' `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true );
}
process
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	Set-StrictMode -Version Latest;

	$LibraryName = $Name;

	if ( $PSCmdlet.ShouldProcess( $LibraryName, "Create Open Office macro library from source directory" ) )
	{

		$DestinationLibraryPath = $Destination;

		if ( Test-Path -Path $DestinationLibraryPath )
		{
			if ( -not $Force )
			{
				Write-Error -Message "Destination library path ""$DestinationLibraryPath"" exists.";
			};
			Remove-Item -Path $DestinationLibraryPath -Recurse -Force `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
		};
		New-Item -Path $DestinationLibraryPath -ItemType Directory `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true ) `
		| Out-Null;

		$saxTransform = $saxExecutable.Load30();

		[System.String] $BaseUri = ( [System.Uri] ( $LiteralPath + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri.ToString().Replace(' ', '%20');
		Write-Verbose "Source base URI: $( $BaseUri )";

		$saxTransform.BaseOutputURI = (
			[System.Uri] ( $DestinationLibraryPath + [System.IO.Path]::DirectorySeparatorChar )
		).AbsoluteUri.ToString().Replace(' ', '%20');
		Write-Verbose "Destination base URI: $( $saxTransform.BaseOutputURI )";

		$Params = [System.Collections.Generic.Dictionary[[Saxon.Api.QName], [Saxon.Api.XdmValue]]]::new();
		$Params.Add(
			[Saxon.Api.QName]::new( 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
				'source-directory' ),
			[Saxon.Api.XdmAtomicValue]::new( $BaseUri )
		);
		$Params.Add(
			[Saxon.Api.QName]::new( 'http://openoffice.org/2000/library', 'name' ),
			[Saxon.Api.XdmAtomicValue]::new( $LibraryName )
		);
		$saxTransform.SetInitialTemplateParameters( $Params, $false );

		$null = $saxTransform.CallTemplate(
			[Saxon.Api.QName]::new( 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
				'build-macro-library' )
		);

		Write-Verbose "Macros library $LibraryName is ready in ""$DestinationLibraryPath"".";
	};
};

