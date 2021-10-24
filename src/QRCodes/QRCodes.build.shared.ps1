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
	-Jobs {
	$NuGetFolder = "$QRCodeToolsPath/.nuget";
	if ( -not ( Test-Path -Path $NuGetFolder ) )
	{
		New-Item -Path $NuGetFolder -ItemType Directory `
			-Verbose:( $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
			-Debug:( $DebugPreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
		| Out-Null;
	};
	$NugetURI = 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe';
	$NugetPath = "$NuGetFolder/nuget.exe";
	Invoke-WebRequest $NugetURI -OutFile $NugetPath `
		-Verbose:( $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
		-Debug:( $DebugPreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue );

	. $NugetPath restore $QRCodePackagesConfig -PackagesDirectory "$QRCodeToolsPath/packages";

	foreach ( $packageFile in $Outputs )
	{
		if ( -not ( Test-Path -Path $packageFile ) )
		{
			Write-Error "Не удалось установить требуемый файл '$packageFile'.";
		};
		& $UpdateFileLastWriteTimePath -LiteralPath $packageFile;
	};

};
