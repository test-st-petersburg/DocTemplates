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

[System.String[]] $SourceXCardsFiles = @(
	$SourceXCardPath | Where-Object { Test-Path -Path $_ } |
	Get-ChildItem -File -Filter '*.xml' | Select-Object -ExpandProperty FullName
);

# Synopsis: Удаляет каталоги с временными файлами, подготовленными .vcf и изображениями QR кодов
task clean {
	Remove-BuildItem $DestinationVCardPath, $DestinationQRCodesVCardPath;
};

# Synopsis: Создаёт vCard из xCard
task BuildVCards;

# Synopsis: Создаёт файлы с изображениями QR кодов (с vCard)
task BuildVCardQRCodes;

foreach ( $SourceXCardFile in $SourceXCardsFiles )
{
	$cardName = [System.IO.Path]::GetFileNameWithoutExtension( $SourceXCardFile );
	$QRCodeName = "$cardName.png";
	$BuildTaskName = "Build-$QRCodeName";
	$sources = $SourceXCardFile;
	$target = Join-Path -Path $DestinationQRCodesVCardPath -ChildPath $QRCodeName;
	$vCardName = "$cardName.vcf";
	$BuildVCardTaskName = "Build-$vCardName";
	$vCardTarget = Join-Path -Path $DestinationVCardPath -ChildPath $vCardName;

	task $BuildVCardTaskName `
		-Before BuildVCards `
		-Inputs $sources `
		-Outputs $vCardTarget `
	{
		$vCardFile = $Outputs;
		$SourceXCardFile = $Inputs[0];

		Write-Verbose "Generate vCard `"$vCardFile`" from xCard `"$SourceXCardFile`"";
		if ( -not ( Test-Path -Path $DestinationVCardPath ) )
		{
			New-Item -Path $DestinationVCardPath -ItemType Directory `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true ) `
			| Out-Null;
		};

		& $OutVCardPath -LiteralPath $SourceXCardFile -Destination $vCardFile `
			-Compatibility 'Android' -Minimize `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
	};

	task $BuildTaskName `
		-Before BuildVCardQRCodes `
		-Inputs $vCardTarget `
		-Outputs $target `
		-Jobs $BuildVCardTaskName, QRCodes-tools,
	{
		$DestinationQRCodeFile = $Outputs;
		$vCardFile = $Inputs[0];

		Write-Verbose "Generate QR code file `"$DestinationQRCodeFile`" from vCard `"$vCardFile`"";
		if ( -not ( Test-Path -Path $DestinationQRCodesVCardPath ) )
		{
			New-Item -Path $DestinationQRCodesVCardPath -ItemType Directory `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true ) `
			| Out-Null;
		};

		Get-Content -LiteralPath $vCardFile -Raw `
		| & $OutQRCodePath -FilePath $DestinationQRCodeFile `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
	};
};

task . BuildVCards, BuildVCardQRCodes;
