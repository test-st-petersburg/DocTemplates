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
	$LiteralPath,

	# массив путей к пакетам XSLT, необходимых для компиляции трансформации
	[Parameter( Mandatory = $False )]
	[System.String[]]
	$PackagePath
)

Function Write-CompilerWarningAndErrors {
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
	foreach ( $Error in $ErrorList ) {
		if ( $Error.ModuleUri.LocalPath.Length -eq 0 ) {
			[System.Uri] $ModuleUriAux = $ModuleUri;
		}
		else {
			[System.Uri] $ModuleUriAux = $Error.ModuleUri;
		};
		if ( $Error.isWarning ) {
			Write-Warning `
				-Message @"

$($Error.Message)
$( $ModuleUriAux.LocalPath ):$($Error.LineNumber) знак:$($Error.ColumnNumber)
"@;
		}
		else {
			$ErrorsCount++;
			Write-Error `
				-Message @"

ERROR: $($Error.Message)
$( $ModuleUriAux.LocalPath ):$($Error.LineNumber) знак:$($Error.ColumnNumber)
"@ `
				-ErrorAction Continue;
		};
	};
	if ( $ErrorsCount ) {
		Write-Error -Message "Compiler errors total: $ErrorsCount";
	};

}

try {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	$saxonPackage = Get-Package -Name 'Saxon-HE' -MinimumVersion 9.8 -MaximumVersion 9.999 `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	$saxonLibPath = Join-Path -Path ( Split-Path -Path ( $saxonPackage.Source ) -Parent ) `
		-ChildPath 'lib\net40\saxon9he-api.dll';
	Add-Type -Path $saxonLibPath `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	Write-Verbose 'Создание SAX процессора.';
	$saxProcessor = New-Object Saxon.Api.Processor;
	Write-Verbose 'Создание SAX XSLT 3.0 компилятора.';
	$saxCompiler = $saxProcessor.NewXsltCompiler();

	foreach ( $Package in $PackagePath ) {
		$XSLTPackagePath = ( Resolve-Path -Path $Package ).Path;
		if ( $PSCmdlet.ShouldProcess( $XSLTPackagePath, 'Compile XSLT package' ) ) {
			try {
				$saxPackage = $saxCompiler.CompilePackage(
					( New-Object System.IO.FileStream -ArgumentList $XSLTPackagePath, 'Open' )
				);
				Write-CompilerWarningAndErrors -ErrorList ( $saxCompiler.ErrorList ) `
					-ModuleUri $XSLTPackagePath `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
				if ( $PSCmdlet.ShouldProcess( $XSLTPackagePath, 'Import XLST package' ) ) {
					$saxCompiler.ImportPackage( $saxPackage );
				};
			}
			catch {
				Write-CompilerWarningAndErrors -ErrorList ( $saxCompiler.ErrorList ) `
					-ModuleUri $XSLTPackagePath `
					-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
				throw;
			};
		};
	};

	try {
		Write-Verbose "Компиляция XSLT преобразования $LiteralPath";
		$saxExecutable = $saxCompiler.Compile( $LiteralPath );
		Write-CompilerWarningAndErrors -ErrorList ( $saxCompiler.ErrorList ) `
			-ModuleUri $LiteralPath `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
	}
	catch {
		Write-CompilerWarningAndErrors -ErrorList ( $saxCompiler.ErrorList ) `
			-ModuleUri $LiteralPath `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true );
		throw;
	};
	return $saxExecutable;
}
catch {
	Write-Error -ErrorRecord $_;
	throw;
};
