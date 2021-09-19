# Copyright © 2020 Sergei S. Betke

<#
	.SYNOPSIS
		Создаёт для последующего включения в состав документа либо шаблона документа каталог контейнера,
		содержащего единственную библиотеку макросов, из папки библиотеки
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	# путь к папке библиотеки
	[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
	[System.String]
	$Path,

	# путь к папке, в которой будет создан контейнер библиотеки
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

	$saxExecutable = . ( Join-Path -Path $PSScriptRoot -ChildPath '.\..\xslt\Get-XSLTExecutable.ps1' ) `
		-PackagePath ( `
			'xslt/system/uri.xslt', `
			'xslt/system/fix-saxon.xslt', `
			'xslt/formatter/basic.xslt', 'xslt/formatter/OO.xslt', `
			'xslt/OODocumentProcessor/oo-writer.xslt', `
			'xslt/OODocumentProcessor/oo-macrolib.xslt' ) `
		-Path 'xslt/Build-OOMacroLib.xslt' `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
}
process
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	$LibraryName = Split-Path -Path $Path -Leaf;

	if ( $PSCmdlet.ShouldProcess( $LibraryName, "Create Open Office macro library container from library directory" ) )
	{

		$DestinationContainerPath = Join-Path -Path $DestinationPath -ChildPath $LibraryName;

		if ( Test-Path -Path $DestinationContainerPath )
		{
			if ( -not $Force )
			{
				Write-Error -Message "Destination container path ""$DestinationContainerPath"" exists.";
			};
			Remove-Item -Path $DestinationContainerPath -Recurse -Force `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};
		New-Item -Path $DestinationContainerPath -ItemType Directory `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true ) `
		| Out-Null;

		$saxTransform = $saxExecutable.Load30();
		$saxTransform.SchemaValidationMode = [Saxon.Api.SchemaValidationMode]::None;

		# TODO: Решить проблему с использованием [System.Uri]::EscapeUriString
		[System.Uri] $BaseUri = ( [System.Uri] ( $Path + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri;
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
