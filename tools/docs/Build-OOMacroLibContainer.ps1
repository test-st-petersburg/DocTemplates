# Copyright © 2020 Sergei S. Betke

<#
	.SYNOPSIS
		Создаёт для последующего включения в состав документа либо шаблона документа каталог контейнера,
		содержащего единственную библиотеку макросов, из папки библиотеки
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	# пути к папке с исходными файлами библиотек
	[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $false )]
	[Alias( 'Path' )]
	[Alias( 'PSPath' )]
	[ValidateNotNullOrEmpty()]
	[System.String]
	$LiteralPath,

	# путь к контейнеру библиотеки
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

	if ( $PSCmdlet.ShouldProcess( $LibraryName, "Create Open Office macro library container from library directory" ) )
	{
		$DestinationContainerPath = $Destination;
		if ( Test-Path -Path $DestinationContainerPath )
		{
			if ( -not $Force )
			{
				Write-Error -Message "Destination container path ""$DestinationContainerPath"" exists.";
			};
			Remove-Item -LiteralPath $DestinationContainerPath -Recurse -Force `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
		};
		New-Item -Path $DestinationContainerPath -ItemType Directory `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true ) `
		| Out-Null;

		$saxTransform = $saxExecutable.Load30();
		$saxTransform.SchemaValidationMode = [Saxon.Api.SchemaValidationMode]::None;

		# TODO: Решить проблему с использованием [System.Uri]::EscapeUriString
		[System.Uri] $BaseUri = ( [System.Uri] ( $LiteralPath + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri;
		Write-Verbose "Source base URI: $( $BaseUri )";

		# TODO: Решить проблему с использованием [System.Uri]::EscapeUriString
		[System.Uri] $BaseOutputURI = ( [System.Uri] ( $DestinationContainerPath + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri;
		$saxTransform.BaseOutputURI = $BaseOutputURI;
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
				'build-macro-library-container' )
		);

		Write-Verbose "Macros library $LibraryName container is ready in ""$DestinationContainerPath"".";
	};

};
