# Copyright © 2020 Sergei S. Betke

<#
	.SYNOPSIS
		Создаёт для последующего включения в состав документа либо шаблона документа каталог контейнера,
		содержащего единственную библиотеку макросов, из папки библиотеки
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true, DefaultParameterSetName = 'Path' )]
param(
	# пути к папкам с исходными файлами библиотек (возможны символы подстановки)
	[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Path' )]
	[System.String[]]
	$Path,

	# пути к папкам с исходными файлами библиотек
	[Parameter( Mandatory = $true, ParameterSetName = 'LiteralPath' )]
	[System.String[]]
	$LiteralPath,

	# путь к контейнеру библиотеки
	# (непосредственно к контейнеру библиотеки, либо к каталогу, в котором будет создан контейнер, если использован ключ Container)
	[Parameter( Mandatory = $true, Position = 1, ValueFromPipeline = $false )]
	[System.String]
	$Destination,

	# Destination указывает путь непосредственно к контейнеру библиотеки без указания этого ключа
	# либо к каталогу, в котором будет создан контейнер, если использован ключ
	[Parameter()]
	[Switch]
	$Container,

	# перезаписать существующие каталоги и файлы
	[Parameter()]
	[Switch]
	$Force
)

begin
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	$saxExecutable = & $PSScriptRoot/../xslt/Get-XSLTExecutable.ps1 `
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

	if ( $PSCmdlet.ParameterSetName -eq 'Path' )
	{
		$LiteralPath = @( $Path | Resolve-Path | Select-Object -ExpandProperty Path );
	}
	[bool] $DestinationIsContainer = $Container;
	if ( $LiteralPath.Count -gt 1 )
	{
		$DestinationIsContainer = $true;
	};
	foreach ( $sourceLiteralPath in $LiteralPath )
	{
		$LibraryName = Split-Path -Path $sourceLiteralPath -Leaf;

		if ( $PSCmdlet.ShouldProcess( $LibraryName, "Create Open Office macro library container from library directory" ) )
		{
			if ( $DestinationIsContainer )
			{
				$DestinationContainerPath = Join-Path -Path $Destination -ChildPath $LibraryName;
			}
			else
			{
				$DestinationContainerPath = $Destination;
			};

			if ( Test-Path -Path $DestinationContainerPath )
			{
				if ( -not $Force )
				{
					Write-Error -Message "Destination container path ""$DestinationContainerPath"" exists.";
				};
				Remove-Item -LiteralPath $DestinationContainerPath -Recurse -Force `
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
			[System.Uri] $BaseUri = ( [System.Uri] ( $sourceLiteralPath + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri;
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

};
