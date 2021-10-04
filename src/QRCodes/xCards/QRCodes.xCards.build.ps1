# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0
#Requires -Modules InvokeBuild

param(
	[Parameter( Position = 0 )]
	[System.String[]]
	$Tasks,

	# путь к корневой папке репозитория
	[System.String]
	$RepoRootPath = ( . {
			if ( [System.IO.Path]::GetFileName( $MyInvocation.ScriptName ) -ne 'Invoke-Build.ps1' )
			{
				( Resolve-Path -Path "$PSScriptRoot/../../.." ).Path
			}
			else
			{
				( Resolve-Path -Path "$( ( Get-Location ).Path )/../../.." ).Path
			};
		}
	),

	# путь к папке с QR кодами, содержащими генерируемые визитные карты vCard
	[System.String]
	$DestinationQRCodesVCardPath = 'tmp/QRCodes/vCards',

	# путь к папке с файлами vCard
	[System.String]
	$DestinationVCardPath = 'tmp/vCards',

	# путь к папке с исходными файлами визитных карт xCard v4
	[System.String]
	$SourceQRCodesXCardPath = 'src/QRCodes/xCards'
)

Set-StrictMode -Version Latest;
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

$parameters = $PSBoundParameters;
$parameters['RepoRootPath'] = $RepoRootPath;

if ( [System.IO.Path]::GetFileName( $MyInvocation.ScriptName ) -ne 'Invoke-Build.ps1' )
{
	Invoke-Build -Task $Tasks -File $MyInvocation.MyCommand.Path @parameters;
	return;
};

if ( -not [System.IO.Path]::IsPathRooted( $DestinationVCardPath ) )
{
	$DestinationVCardPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$RepoRootPath/$DestinationVCardPath" );
};

if ( -not [System.IO.Path]::IsPathRooted( $DestinationQRCodesVCardPath ) )
{
	$DestinationQRCodesVCardPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$RepoRootPath/$DestinationQRCodesVCardPath" );
};

if ( -not [System.IO.Path]::IsPathRooted( $SourceQRCodesXCardPath ) )
{
	$SourceQRCodesXCardPath = ( Join-Path -Path $RepoRootPath -ChildPath $SourceQRCodesXCardPath -Resolve );
};

[System.String] $ToolsPath = ( Resolve-Path -Path $RepoRootPath/tools ).Path;
[System.String] $QRCodeToolsPath = ( Resolve-Path -Path $ToolsPath/QRCode ).Path;
[System.String] $OutQRCodePath = ( Resolve-Path -Path $QRCodeToolsPath/Out-QRCode.ps1 ).Path;
[System.String] $vCardToolsPath = ( Resolve-Path -Path $ToolsPath/xCard ).Path;
[System.String] $OutVCardPath = ( Resolve-Path -Path $vCardToolsPath/Out-vCardFile.ps1 ).Path;

[System.String[]] $SourceXCardsFiles = @(
	$SourceQRCodesXCardPath | Where-Object { Test-Path -Path $_ } |
	Get-ChildItem -File -Filter '*.xml' | Select-Object -ExpandProperty FullName
);

# Synopsis: Удаляет каталоги с временными файлами, собранными библиотеками макрокоманд
task Clean {
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
	$prerequisites = $SourceXCardFile;
	$target = Join-Path -Path $DestinationQRCodesVCardPath -ChildPath $QRCodeName;
	$vCardName = "$cardName.vcf";
	$BuildVCardTaskName = "Build-$vCardName";
	$vCardTarget = Join-Path -Path $DestinationVCardPath -ChildPath $vCardName;

	task $BuildVCardTaskName `
		-Before BuildVCards `
		-Inputs $prerequisites `
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
		-Jobs $BuildVCardTaskName,
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
