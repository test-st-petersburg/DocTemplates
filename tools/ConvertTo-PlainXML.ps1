<#
	.SYNOPSIS
		Преобразовать open office файлов в папки с xml файлами для последующего
		хранения в git репозиториях
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	#
	[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $false )]
	[Alias( "ODT_File" )]
	[Alias( "ODTFile" )]
	[Alias( "OTT_File" )]
	[Alias( "OTTFile" )]
	[System.String]
	$FilePath,

	[Parameter( Mandatory = $True, Position = 1, ValueFromPipeline = $false )]
	[Alias( "Directory" )]
	[System.String]
	$DestinationPath,

	# форматировать структуру xml файлов
	[Parameter()]
	[Switch]
	$Indented
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

if ( $PSCmdlet.ShouldProcess( $FilePath, "Convert Open Office document to plain XML directory" ) ) {
	$TempZIPFileName = [System.IO.Path]::GetTempFileName() + '.zip';
	Copy-Item -Path $FilePath -Destination $TempZIPFileName `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	$DestinationDirName = ( Get-Item $FilePath ).Name;
	$DestinationPathForFile = Join-Path -Path $DestinationPath -ChildPath $DestinationDirName;
	Expand-Archive -Path $TempZIPFileName -DestinationPath $DestinationPathForFile `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	Remove-Item -Path $TempZIPFileName `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
};
