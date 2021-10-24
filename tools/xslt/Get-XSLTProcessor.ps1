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

	# $saxonPackage = Get-Package -Name 'Saxon-HE' -MinimumVersion 9.8 -MaximumVersion 9.8.999 `
	# 	-ProviderName NuGet `
	# 	-SkipDependencies `
	# 	-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
	# 	-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
	# $saxonLibPath = Join-Path -Path ( Split-Path -Path ( $saxonPackage.Source ) -Parent ) `
	# 	-ChildPath 'lib\net40\saxon9he-api.dll';

	[System.String] $saxonLibPath = (
		Select-Xml -LiteralPath "$PSScriptRoot/packages.config" `
			-XPath 'packages/package[ @id = "Saxon-HE" ]' |
		Select-Object -ExpandProperty Node -First 1 |
		ForEach-Object {
			( Get-ChildItem -LiteralPath "$PSScriptRoot/packages/$( $_.id ).$( $_.version )/lib/$( $_.targetFramework )" `
					-Filter 'saxon*api*.dll' ).FullName;
		}
	);

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
	$PScmdlet.ThrowTerminatingError();
};
