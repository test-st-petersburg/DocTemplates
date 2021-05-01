# Copyright © 2020 Sergei S. Betke

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

	# массив путей к пакетам XSLT, необходимых для компиляции трансформации
	[Parameter( Mandatory = $False )]
	[System.String[]]
	$PackagePath,

	# путь к DTD файлам
	[Parameter( Mandatory = $False )]
	[System.String]
	$DtdPath

)

Function Write-CompilerWarningAndErrors
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
	foreach ( $Error in $ErrorList )
 {
		if ( $Error.ModuleUri.LocalPath.Length -eq 0 )
		{
			[System.Uri] $ModuleUriAux = $ModuleUri;
		}
		else
		{
			[System.Uri] $ModuleUriAux = $Error.ModuleUri;
		};
		if ( $Error.isWarning )
		{
			Write-Warning `
				-Message @"

$($Error.Message)
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
"@ `
				-ErrorAction Continue;
		};
	};
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

	$saxonLibPath = Join-Path -Path $PSScriptRoot -ChildPath 'packages\Saxon-HE.9.8.0.15\lib\net40\saxon9he-api.dll';
	Add-Type -Path $saxonLibPath `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

	Write-Verbose 'Создание SAX процессора.';
	$saxProcessor = New-Object Saxon.Api.Processor;
	$XmlResolverWithCachedDTD = New-Object OOXmlResolver -ArgumentList ( ( Resolve-Path -Path $DtdPath ).Path );
	$saxProcessor.XmlResolver = $XmlResolverWithCachedDTD;
	$saxProcessor.SetProperty( 'http://saxon.sf.net/feature/ignoreSAXSourceParser', 'true' );
	$saxProcessor.SetProperty( 'http://saxon.sf.net/feature/preferJaxpParser', 'false' );

	Write-Verbose 'Создание SAX XSLT 3.0 компилятора.';
	$saxCompiler = $saxProcessor.NewXsltCompiler();

	foreach ( $Package in $PackagePath )
	{
		$XSLTPackagePath = ( Resolve-Path -Path $Package ).Path;
		if ( $PSCmdlet.ShouldProcess( $XSLTPackagePath, 'Compile XSLT package' ) )
		{
			try
			{
				$saxCompiler.BaseUri = $XSLTPackagePath;
				$saxPackage = $saxCompiler.CompilePackage(
					( New-Object System.IO.FileStream -ArgumentList $XSLTPackagePath, 'Open' )
				);
				Write-CompilerWarningAndErrors -ErrorList ( $saxCompiler.ErrorList ) `
					-ModuleUri $XSLTPackagePath `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
				if ( $PSCmdlet.ShouldProcess( $XSLTPackagePath, 'Import XSLT package' ) )
				{
					$saxCompiler.ImportPackage( $saxPackage );
				};
			}
			catch
			{
				Write-CompilerWarningAndErrors -ErrorList ( $saxCompiler.ErrorList ) `
					-ModuleUri $XSLTPackagePath `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
				throw;
			};
		};
	};

	$LiteralPath = ( Resolve-Path -Path $Path ).Path;
	if ( $PSCmdlet.ShouldProcess( $LiteralPath, 'Компиляция XSLT преобразования' ) )
	{
		try
		{
			$saxExecutable = $saxCompiler.Compile( $LiteralPath );
			Write-CompilerWarningAndErrors -ErrorList ( $saxCompiler.ErrorList ) `
				-ModuleUri $LiteralPath `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
		}
		catch
		{
			Write-CompilerWarningAndErrors -ErrorList ( $saxCompiler.ErrorList ) `
				-ModuleUri $LiteralPath `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
			throw;
		};
		return $saxExecutable;
	};
}
catch
{
	Write-Error -ErrorRecord $_;
	throw;
};
