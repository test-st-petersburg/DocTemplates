#Requires -Version 5.0
#Requires -Modules InvokeBuild

param(
	# путь к корневой папке проекта
	[System.String]
	$ProjectRoot = ( property ProjectRoot (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $PSScriptRoot -ChildPath '.\..\..' )
			)
		) ),

	# путь к папке с исходными файлами
	[System.String]
	$SourcePath = ( property SourcePath (
			( Resolve-Path -Path `
				( Join-Path -Path $ProjectRoot -ChildPath 'src' )
			).Path
		) ),

	# путь к папке с xCard .xml файлами для генерации QR кодов
	[System.String]
	$SourceXCardPath = ( property SourceXCardPath (
			( Resolve-Path -Path `
				( Join-Path -Path $SourcePath -ChildPath 'QRCodes\xCards' )
			).Path
		) ),

	# пути к .url файлам для генерации QR кодов
	[System.String[]]
	$SourceXCardsFiles = ( property SourceXCardsFiles @(
			$SourceXCardPath | Where-Object { Test-Path -Path $_ } |
			Get-ChildItem -File -Filter '*.xml' | Select-Object -ExpandProperty FullName
		) ),

	# путь к папке с генерируемыми файлами
	[System.String]
	$DestinationPath = ( property DestinationPath (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $ProjectRoot -ChildPath 'output' )
			)
		) ),

	# путь к папке с генерируемыми файлами, используемыми только для выполнения других задач
	[System.String]
	$TempPath = ( property TempPath (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $ProjectRoot -ChildPath 'tmp' )
			)
		) ),

	# путь к временной папке со сгенерированными vCard
	[System.String]
	$DestinationVCardPath = ( property DestinationVCardPath (
			Join-Path -Path $TempPath -ChildPath 'vCards'
		) ),

	# путь к временной папке со сгенерированными изображениями QR кодов
	[System.String]
	$DestinationQRCodesPath = ( property DestinationQRCodesPath (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $TempPath -ChildPath 'QRCodes' )
			)
		) ),

	# версия шаблонов и файлов
	[System.String]
	$Version
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

use '.\..\..\tools\xCard' Out-vCardFile.ps1;
use '.\..\..\tools\QRCode' Out-QRCode.ps1;

# Synopsis: Удаляет каталоги с временными и собранными файлами
task Clean {
	remove $DestinationVCardPath, $DestinationQRCodesPath;
};

$BuildVCardQRCodesTasks = @();
foreach ( $SourceXCardFile in $SourceXCardsFiles )
{
	$cardName = [System.IO.Path]::GetFileNameWithoutExtension( $SourceXCardFile );
	$QRCodeName = "$cardName.png";
	$BuildTaskName = "Build-$QRCodeName";
	$BuildVCardQRCodesTasks += $BuildTaskName;
	$prerequisites = $SourceXCardFile;
	$target = Join-Path -Path $DestinationQRCodesPath -ChildPath $QRCodeName;
	$vCardName = "$cardName.vcf";
	$BuildVCardTaskName = "Build-$vCardName";
	$vCardTarget = Join-Path -Path $DestinationVCardPath -ChildPath $vCardName;

	task $BuildVCardTaskName `
		-Inputs $prerequisites `
		-Outputs $vCardTarget `
	{
		$vCardFile = $Outputs;
		$SourceXCardFile = $Inputs[0];

		Write-Verbose "Generate vCard `"$vCardFile`" from xCard `"$SourceXCardFile`"";
		if ( -not ( Test-Path -Path $DestinationVCardPath ) )
		{
			New-Item -Path $DestinationVCardPath -ItemType Directory `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true ) `
			| Out-Null;
		};

		Out-vCardFile.ps1 -LiteralPath $SourceXCardFile -Destination $vCardFile `
			-Compatibility 'Android' -Minimize `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};

	task $BuildTaskName `
		-Inputs $vCardTarget `
		-Outputs $target `
		-Jobs $BuildVCardTaskName,
	{
		$DestinationQRCodeFile = $Outputs;
		$vCardFile = $Inputs[0];

		Write-Verbose "Generate QR code file `"$DestinationQRCodeFile`" from vCard `"$vCardFile`"";
		if ( -not ( Test-Path -Path $DestinationQRCodesPath ) )
		{
			New-Item -Path $DestinationQRCodesPath -ItemType Directory `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true ) `
			| Out-Null;
		};

		Get-Content -LiteralPath $vCardFile -Raw `
		| Out-QRCode.ps1 -FilePath $DestinationQRCodeFile `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};
};

# Synopsis: Создаёт файлы с изображениями QR кодов (с vCard)
task BuildVCardQRCodes $BuildVCardQRCodesTasks;

task Build BuildVCardQRCodes;

task . Build;
