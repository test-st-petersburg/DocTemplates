﻿# Copyright © 2020 Sergei S. Betke

<#
	.SYNOPSIS
		Возвращает исполняемый объект XSLT трансформации на базе Saxon HE.
#>

#Requires -Version 5.0

[CmdletBinding()]

Param(

	# путь к файлу XSLT
	[Parameter( Mandatory = $True, Position = 0 )]
	[System.String]
	$Path,

	# компилятор XSLT
	[Parameter( Mandatory = $False )]
	$saxCompiler,

	# массив путей к пакетам XSLT, необходимых для компиляции трансформации
	[Parameter( Mandatory = $False )]
	[System.String[]]
	$PackagePath,

	# путь к DTD файлам
	[Parameter( Mandatory = $False )]
	[System.String]
	$DtdPath

)

Function Write-CompilerWarningAndError
{
	[CmdletBinding()]
	Param(
		# список ошибок
		[Parameter( Mandatory = $True, Position = 0 )]
		$ErrorList,

		# компилируемый модуль
		[Parameter( Mandatory = $False )]
		[System.Uri]
		$ModuleUri
	)

	[int] $ErrorsCount = 0;
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Continue;
	foreach ( $Error in $ErrorList )
	{
		if ( $Error.ModuleUri )
		{
			[System.Uri] $ModuleUriAux = $Error.ModuleUri;
		}
		else
		{
			[System.Uri] $ModuleUriAux = $ModuleUri;
		};
		if ( $Error.isWarning )
		{
			Write-Warning `
				-Message @"

WARNING: $($Error.Message)
$( $ModuleUriAux.LocalPath ):$($Error.LineNumber) знак:$($Error.ColumnNumber)
"@;
		}
		else
		{
			$ErrorsCount++;
			Write-Error `
				-Message @"

ERROR: $($Error.Message)
$( $ModuleUriAux.LocalPath ):$($Error.LineNumber) знак:$($Error.ColumnNumber)
"@;
		};
	};
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	if ( $ErrorsCount )
	{
		Write-Error -Message "Compiler errors total: $ErrorsCount";
	};

}

class OOXmlResolver: System.Xml.XmlUrlResolver
{

	[System.String] $DtdPath

	OOXmlResolver( [System.String] $DtdPath )
	{
		$this.DtdPath = $DtdPath;
	}

	[System.Uri]
	ResolveUri ( [System.Uri] $baseUri, [System.String] $relativeUri )
	{
		If ( -not $this.DtdPath )
		{
			return ( [System.Xml.XmlUrlResolver] $this ).ResolveUri( $baseUri, $relativeUri );
		};
		[System.Uri] $DtdFileUri = Join-Path -Path $this.DtdPath -ChildPath $relativeUri;
		If ( Test-Path -Path ( $DtdFileUri.LocalPath ) )
		{
			return $DtdFileUri;
		}
		else
		{
			return ( [System.Xml.XmlUrlResolver] $this ).ResolveUri( $baseUri, $relativeUri );
		};
	}

};

try
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	if ( $null -eq $saxCompiler )
	{
		$saxProcessor = . ( Join-Path -Path $PSScriptRoot -ChildPath '.\Get-XSLTProcessor.ps1' -Resolve ) `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );

		Write-Verbose 'Создание SAX XSLT 3.0 компилятора.';
		$saxCompiler = $saxProcessor.NewXsltCompiler();
	};

	$saxProcessor = $saxCompiler.Processor;

	[System.String] $DataRoot = ( Get-Location ).Path;
	[System.String] $CallingScriptRoot = ( @( Get-PSCallStack )[0].InvocationInfo.PSScriptRoot );
	if ( -not [System.String]::IsNullOrEmpty( $CallingScriptRoot ) )
	{
		$DataRoot = $CallingScriptRoot;
	};

	if ( $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('DtdPath') )
	{
		if ( [System.IO.Path]::IsPathRooted( $DtdPath ) )
		{
			[System.String] $DtdFullPath = $DtdPath;
		}
		else
		{
			[System.String] $DtdFullPath = ( Join-Path -Path $DataRoot -ChildPath $DtdPath -Resolve );
		};
		$XmlResolverWithCachedDTD = [OOXmlResolver]::new( $DtdFullPath );
		$saxProcessor.XmlResolver = $XmlResolverWithCachedDTD;
	};
	$saxProcessor.SetProperty( 'http://saxon.sf.net/feature/ignoreSAXSourceParser', 'true' );
	$saxProcessor.SetProperty( 'http://saxon.sf.net/feature/preferJaxpParser', 'false' );

	foreach ( $Package in $PackagePath )
	{
		if ( [System.IO.Path]::IsPathRooted( $Package ) )
		{
			[System.String] $XSLTPackagePath = $Package;
		}
		else
		{
			[System.String] $XSLTPackagePath = ( Join-Path -Path $DataRoot -ChildPath $Package -Resolve );
		};

		if ( $PSCmdlet.ShouldProcess( $XSLTPackagePath, 'Compile XSLT package' ) )
		{
			try
			{
				$saxCompiler.BaseUri = $XSLTPackagePath;
				$saxCompiler.SetErrorList( [System.Collections.Generic.List[ [Saxon.Api.XmlProcessingError] ]]::new() );
				$saxPackage = $saxCompiler.CompilePackage(
					( [System.IO.FileStream]::new( $XSLTPackagePath, 'Open' ) )
				);
				Write-CompilerWarningAndError -ErrorList ( $saxCompiler.GetErrorList() ) `
					-ModuleUri $XSLTPackagePath `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true );
				if ( $PSCmdlet.ShouldProcess( $XSLTPackagePath, 'Import XSLT package' ) )
				{
					$saxCompiler.SetErrorList( [System.Collections.Generic.List[ [Saxon.Api.XmlProcessingError] ]]::new() );
					$saxCompiler.ImportPackage( $saxPackage );
				};
			}
			catch
			{
				Write-CompilerWarningAndError -ErrorList ( $saxCompiler.GetErrorList() ) `
					-ModuleUri $XSLTPackagePath `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true );
				$PSCmdlet.ThrowTerminatingError(
					[System.Management.Automation.ErrorRecord]::new(
						[Exception]::new( "Compiler error on $XSLTPackagePath." ),
						'XSLTCompilationError',
						[System.Management.Automation.ErrorCategory]::SyntaxError,
						$saxCompiler.ErrorList
					)
				);
			};
		};
	};

	if ( [System.IO.Path]::IsPathRooted( $Path ) )
	{
		[System.String] $LiteralPath = $Path;
	}
	else
	{
		[System.String] $LiteralPath = ( Join-Path -Path $DataRoot -ChildPath $Path -Resolve );
	};
	if ( $PSCmdlet.ShouldProcess( $LiteralPath, 'Компиляция XSLT преобразования' ) )
	{
		try
		{
			$saxCompiler.SetErrorList( [System.Collections.Generic.List[ [Saxon.Api.XmlProcessingError] ]]::new() );
			$saxExecutable = $saxCompiler.Compile( $LiteralPath );
			Write-CompilerWarningAndError -ErrorList ( $saxCompiler.GetErrorList() ) `
				-ModuleUri $LiteralPath `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true );
		}
		catch
		{
			Write-CompilerWarningAndError -ErrorList ( $saxCompiler.GetErrorList() ) `
				-ModuleUri $LiteralPath `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true );
			$PSCmdlet.ThrowTerminatingError(
				[System.Management.Automation.ErrorRecord]::new(
					[Exception]::new( "Compiler error on $LiteralPath." ),
					'XSLTCompilationError',
					[System.Management.Automation.ErrorCategory]::SyntaxError,
					$saxCompiler.ErrorList
				)
			);
		};
		return $saxExecutable;
	};
}
catch
{
	Write-Error -ErrorRecord $_;
	$PScmdlet.ThrowTerminatingError( $_ );
};
