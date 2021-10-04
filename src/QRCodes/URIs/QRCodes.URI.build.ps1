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

	# путь к папке с QR кодами для URI
	[System.String]
	$DestinationQRCodesURIPath = 'tmp/QRCodes/URIs',

	# путь к папке с исходными файлами для генерации QR кодов с URI
	[System.String]
	$SourceQRCodesURIPath = 'src/QRCodes/URIs'
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

if ( -not [System.IO.Path]::IsPathRooted( $DestinationQRCodesURIPath ) )
{
	$DestinationQRCodesURIPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$RepoRootPath/$DestinationQRCodesURIPath" );
};

if ( -not [System.IO.Path]::IsPathRooted( $SourceQRCodesURIPath ) )
{
	$SourceQRCodesURIPath = ( Join-Path -Path $RepoRootPath -ChildPath $SourceQRCodesURIPath -Resolve );
};

[System.String] $ToolsPath = ( Resolve-Path -Path $RepoRootPath/tools ).Path;
[System.String] $QRCodeToolsPath = ( Resolve-Path -Path $ToolsPath/QRCode ).Path;
[System.String] $OutQRCodePath = ( Resolve-Path -Path $QRCodeToolsPath/Out-QRCode.ps1 ).Path;

[System.String[]] $SourceURIsFiles = @(
	$SourceQRCodesURIPath | Where-Object { Test-Path -Path $_ } |
	Get-ChildItem -File -Filter '*.url' | Select-Object -ExpandProperty FullName
);

# Synopsis: Удаляет каталоги с временными файлами, собранными библиотеками макрокоманд
task Clean {
	Remove-BuildItem $DestinationQRCodesURIPath;
};

# Synopsis: Создаёт файлы с изображениями QR кодов (с URL)
task BuildUriQRCodes;

foreach ( $SourceURIFile in $SourceURIsFiles )
{
	$UriName = [System.IO.Path]::GetFileNameWithoutExtension( $SourceURIFile );
	$UriQRCodeName = "$UriName.png";
	$BuildTaskName = "Build-$UriQRCodeName";
	$prerequisites = $SourceURIFile;
	$target = Join-Path -Path $DestinationQRCodesURIPath -ChildPath $UriQRCodeName;

	task $BuildTaskName `
		-Before BuildUriQRCodes `
		-Inputs $prerequisites `
		-Outputs $target `
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
