# Copyright © 2020 Sergei S. Betke

<#
	.SYNOPSIS
		Возвращает процессов XSLT на базе Saxon HE.
#>

#Requires -Version 5.0

[CmdletBinding()]

Param()

try
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	$saxonPackage = Get-Package -Name 'Saxon-HE' -MinimumVersion 9.8 -MaximumVersion 9.8.999 `
		-ProviderName NuGet `
		-SkipDependencies `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
	$saxonLibPath = Join-Path -Path ( Split-Path -Path ( $saxonPackage.Source ) -Parent ) `
		-ChildPath 'lib\net40\saxon9he-api.dll';
	Add-Type -Path $saxonLibPath `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );

	Write-Verbose 'Создание SAX процессора.';
	$saxProcessor = [Saxon.Api.Processor]::new();

	return 	$saxProcessor;
}
catch
{
	Write-Error -ErrorRecord $_;
	throw;
};
