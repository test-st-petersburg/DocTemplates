# Copyright © 2020 Sergei S. Betke

<#
	.SYNOPSIS
		Удаляет мусор в content.xml файлах open office документов
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Medium', SupportsShouldProcess = $true )]
param(
	# путь к каталогу с XML файлами Open Office
	[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $true )]
	[System.String]
	$Path
)

begin
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	$saxExecutable = & $PSScriptRoot/../xslt/Get-XSLTExecutable.ps1 `
		-PackagePath ( `
			'xslt/system/uri.xslt', `
			'xslt/system/fix-saxon.xslt', `
			'xslt/formatter/basic.xslt', 'xslt/formatter/OO.xslt', `
			'xslt/optimizer/OOOptimizer.xslt', `
			'xslt/OODocumentProcessor/oo-writer.xslt', `
			'xslt/OODocumentProcessor/oo-macrolib.xslt', `
			'xslt/OODocumentProcessor/oo-merger.xslt', `
			'xslt/OODocumentProcessor/oo-preprocessor.xslt', `
			'xslt/OODocumentProcessor/oo-document.xslt' ) `
		-Path 'xslt/Transform-PlainXML.xslt' `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
}
process
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	if ( $PSCmdlet.ShouldProcess( $Path, "Optimize Open Office XML files" ) )
	{
		$saxTransform = $saxExecutable.Load30();

		[System.String] $BaseUri = ( [System.Uri] ( $Path + [System.IO.Path]::DirectorySeparatorChar ) ).AbsoluteUri.ToString().Replace(' ', '%20');
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
					'optimize' )
			);

			Write-Verbose 'Transformation done';

			Get-ChildItem -Path $FormatterTempXMLFolder | Copy-Item -Destination $Path -Recurse -Force `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		}
		finally
		{
			Remove-Item -Path $FormatterTempXMLFolder -Recurse `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};

	};
}
