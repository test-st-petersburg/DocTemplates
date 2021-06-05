# Copyright © 2020 Sergei S. Betke

<#
	.SYNOPSIS
		Создаёт каталог библиотеки макросов из папки с "исходными" файлами
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

begin
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	Push-Location -Path $PSScriptRoot;
	$saxExecutable = .\..\xslt\Get-XSLTExecutable.ps1 `
		-PackagePath `
		'xslt/system/uri.xslt', `
		'xslt/system/fix-saxon.xslt', `
		'xslt/formatter/basic.xslt', 'xslt/formatter/OO.xslt', `
		'xslt/OODocumentProcessor/oo-writer.xslt', `
		'xslt/OODocumentProcessor/oo-macrolib.xslt' `
		-Path 'xslt/Build-OOMacroLib.xslt' `
		-DtdPath 'dtd/officedocument/1_0/' `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
	Pop-Location;
}
process
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	$LibraryName = Split-Path -Path $Path -Leaf;

	if ( $PSCmdlet.ShouldProcess( $LibraryName, "Create Open Office macro library from source directory" ) )
	{

		$DestinationLibraryPath = Join-Path -Path $DestinationPath -ChildPath $LibraryName;

		if ( Test-Path -Path $DestinationLibraryPath )
		{
			if ( -not $Force )
			{
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

		$saxTransform = $saxExecutable.Load30();

		[System.String] $BaseUri = ( [System.Uri] ( $Path + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri.ToString().Replace(' ', '%20');
		Write-Verbose "Source base URI: $( $BaseUri )";

		$saxTransform.BaseOutputURI = (
			[System.Uri] ( $DestinationLibraryPath + [System.IO.Path]::DirectorySeparatorChar )
		).AbsoluteUri.ToString().Replace(' ', '%20');
		Write-Verbose "Destination base URI: $( $saxTransform.BaseOutputURI )";

		$Params = New-Object 'System.Collections.Generic.Dictionary[ [Saxon.Api.QName], [Saxon.Api.XdmValue] ]';
		$Params.Add(
			( New-Object Saxon.Api.QName -ArgumentList 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
				'source-directory' ),
			( New-Object Saxon.Api.XdmAtomicValue -ArgumentList $BaseUri )
		)
		$saxTransform.SetInitialTemplateParameters( $Params, $false );

		$null = $saxTransform.CallTemplate(
			( New-Object Saxon.Api.QName -ArgumentList 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor',
				'build-macro-library' )
		);

		Write-Verbose "Macros library $LibraryName is ready in ""$DestinationLibraryPath"".";
	};
};
