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

	# путь к папке с .url файлами для генерации QR кодов
	[System.String]
	$SourceURIsPath = ( property SourceURIsPath (
			( Resolve-Path -Path `
				( Join-Path -Path $SourcePath -ChildPath 'QRCodes\URIs' )
			).Path
		) ),

	# пути к .url файлам для генерации QR кодов
	[System.String[]]
	$SourceURIsFiles = ( property SourceURIsFiles @(
			$SourceURIsPath | Where-Object { Test-Path -Path $_ } |
			Get-ChildItem -File -Filter '*.url' | Select-Object -ExpandProperty FullName
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

# Synopsis: Удаляет каталоги с временными и собранными файлами
task Clean {
	remove $DestinationQRCodesPath;
};

$BuildUriQRCodesTasks = @();
foreach ( $SourceURIFile in $SourceURIsFiles )
{
	$UriName = [System.IO.Path]::GetFileNameWithoutExtension( $SourceURIFile );
	$UriQRCodeName = "$UriName.png";
	$BuildTaskName = "BuildLib-$UriQRCodeName";
	$BuildUriQRCodesTasks += $BuildTaskName;
	$prerequisites = $SourceURIFile;
	$target = Join-Path -Path $DestinationQRCodesPath -ChildPath $UriQRCodeName;

	task $BuildTaskName `
		-Inputs $prerequisites `
		-Outputs $target `
	{
		$DestinationQRCodeFile = $Outputs;
		$SourceUriFile = $Inputs[0];

		Write-Verbose "Generate QR code file `"$DestinationQRCodeFile`" from `"$SourceUriFile`"";
		$SourceURL = Get-Content -LiteralPath $SourceUriFile `
		| Select-String -Pattern '(?<=^URL=\s*).*?(\s*)$'  -AllMatches `
		| Foreach-Object { $_.Matches } | Foreach-Object { $_.Groups[0].Value };
		Write-Verbose "Source URL `"$SourceURL`"";

		if ( -not ( Test-Path -Path $DestinationQRCodesPath ) )
		{
			New-Item -Path $DestinationQRCodesPath -ItemType Directory `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true ) `
			| Out-Null;
		};

		$SourceURL | .\..\..\tools\QRCode\Out-QRCode.ps1 -FilePath $DestinationQRCodeFile `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};
};

# Synopsis: Создаёт файлы с изображениями QR кодов (с URL)
task BuildUriQRCodes $BuildUriQRCodesTasks;

task Build BuildUriQRCodes;

task . Build;
