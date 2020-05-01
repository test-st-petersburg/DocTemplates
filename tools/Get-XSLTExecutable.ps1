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
	$LiteralPath
)

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

	try {
		Write-Verbose 'Компиляция XSLT.';
		$saxExecutable = $saxCompiler.Compile( $LiteralPath );
		foreach ( $Error in $saxCompiler.ErrorList ) {
			Write-Warning `
				-Message @"

$($Error.Message)
$( ( [System.Uri]$Error.ModuleUri ).LocalPath ):$($Error.LineNumber) знак:$($Error.ColumnNumber)
"@;
		};
	}
	catch {
		Write-Error -Message "Ошибок $( $saxCompiler.ErrorList.Count )" -ErrorAction Continue;
		foreach ( $Error in $saxCompiler.ErrorList ) {
			if ( $Error.isWarning ) {
				Write-Warning `
					-Message @"

$($Error.Message)
$( ( [System.Uri]$Error.ModuleUri ).LocalPath ):$($Error.LineNumber) знак:$($Error.ColumnNumber)
"@;
			}
			else {
				Write-Error `
					-Message @"

ERROR: $($Error.Message)
$( ( [System.Uri]$Error.ModuleUri ).LocalPath ):$($Error.LineNumber) знак:$($Error.ColumnNumber)
"@ `
					-ErrorAction Continue;
			};
		};
		throw;
	};
	return $saxExecutable;
}
catch {
	Write-Error -ErrorRecord $_;
};
