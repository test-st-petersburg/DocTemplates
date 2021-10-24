# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0
#Requires -Modules InvokeBuild

param(
	[Parameter( Position = 0 )]
	[System.String[]]
	$Tasks
)

Set-StrictMode -Version Latest;
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

$parameters = $PSBoundParameters;

if ( [System.IO.Path]::GetFileName( $MyInvocation.ScriptName ) -ne 'Invoke-Build.ps1' )
{
	Invoke-Build -Task $Tasks -File $MyInvocation.MyCommand.Path @parameters;
	return;
};

. $PSScriptRoot/../QRCodes.build.shared.ps1

[System.String[]] $SourceURIsFiles = @(
	$SourceURIsPath | Where-Object { Test-Path -Path $_ } |
	Get-ChildItem -File -Filter '*.url' | Select-Object -ExpandProperty FullName
);

# Synopsis: Удаляет каталоги с временными файлами, подготовленными изображениями QR кодов
task clean {
	Remove-BuildItem $DestinationQRCodesURIPath;
};

task pre-build nuget, QRCodes-tools;

# Synopsis: Создаёт файлы с изображениями QR кодов (с URL)
task BuildUriQRCodes;

foreach ( $SourceURIFile in $SourceURIsFiles )
{
	$UriName = [System.IO.Path]::GetFileNameWithoutExtension( $SourceURIFile );
	$UriQRCodeName = "$UriName.png";
	$BuildTaskName = "Build-$UriQRCodeName";
	$sources = $SourceURIFile;
	$target = Join-Path -Path $DestinationQRCodesURIPath -ChildPath $UriQRCodeName;

	task $BuildTaskName `
		-Before BuildUriQRCodes `
		-Inputs $sources `
		-Outputs $target `
		-Jobs QRCodes-tools,
	{
		$DestinationQRCodeFile = $Outputs;
		$SourceUriFile = $Inputs[0];

		Write-Verbose "Generate QR code file `"$DestinationQRCodeFile`" from `"$SourceUriFile`"";
		$SourceURL = Get-Content -LiteralPath $SourceUriFile `
		| Select-String -Pattern '(?<=^URL=\s*).*?(\s*)$' -AllMatches `
		| Foreach-Object { $_.Matches } | Foreach-Object { $_.Groups[0].Value };
		Write-Verbose "Source URL `"$SourceURL`"";

		if ( -not ( Test-Path -Path $DestinationQRCodesURIPath ) )
		{
			New-Item -Path $DestinationQRCodesURIPath -ItemType Directory `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true ) `
			| Out-Null;
		};

		$SourceURL | & $OutQRCodePath -FilePath $DestinationQRCodeFile `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
	};

};

task . BuildUriQRCodes;
