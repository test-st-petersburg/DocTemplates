# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

Set-StrictMode -Version Latest;

. $PSScriptRoot/../common.build.shared.ps1

[System.String] $QRCodePackagesConfig = Join-Path -Path $QRCodeToolsPath -ChildPath 'packages.config';
[System.String] $OutputLibFiles = @(
	Select-Xml -LiteralPath $QRCodePackagesConfig `
		-XPath 'packages/package' `
	| Select-Object -ExpandProperty Node `
	| ForEach-Object {
		"$QRCodeToolsPath/packages/$( $_.id ).$( $_.version )/lib/$( $_.targetFramework )/$( $_.id ).dll"
	}
);

task QRCodes-tools `
	-Inputs @( $QRCodePackagesConfig ) `
	-Outputs $OutputLibFiles `
	-Jobs nuget, {

	. $NuGetPath restore $QRCodePackagesConfig -PackagesDirectory "$QRCodeToolsPath/packages";

	foreach ( $packageFile in $Outputs )
	{
		if ( -not ( Test-Path -Path $packageFile ) )
		{
			Write-Error "Не удалось установить требуемый файл '$packageFile'.";
		};
		& $UpdateFileLastWriteTimePath -LiteralPath $packageFile;
	};

};
