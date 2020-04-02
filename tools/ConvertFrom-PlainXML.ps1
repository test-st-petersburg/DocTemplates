<#
	.SYNOPSIS
		Создаёт open office файлы из папки с xml файлами
#>

#Requires -Version 5.0

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	# путь к папке с xml файлами
	[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $false )]
	[Alias( "Directory" )]
	[System.String]
	$Path,

	# путь к файлу Open Office, который будет создан
	[Parameter( Mandatory = $True, Position = 1, ValueFromPipeline = $false )]
	[Alias( "ODT_File" )]
	[Alias( "ODTFile" )]
	[Alias( "OTT_File" )]
	[Alias( "OTTFile" )]
	[System.String]
	$DestinationPath,

	# перезаписать существующий файл
	[Parameter()]
	[Switch]
	$Force
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

if ( $PSCmdlet.ShouldProcess( $FilePath, "Create Open Office document from plain XML directory" ) ) {
	$TempZIPFileName = [System.IO.Path]::GetTempFileName() + '.zip';
	Compress-Archive -Path ( Join-Path -Path $Path -ChildPath 'mimetype' ) `
		-DestinationPath $TempZIPFileName  `
		-CompressionLevel NoCompression `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	Get-ChildItem -Path $Path -Exclude 'mimetype' `
	| Compress-Archive `
		-DestinationPath $TempZIPFileName `
		-Update `
		-CompressionLevel Fastest `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	Move-Item -Path $TempZIPFileName -Destination $DestinationPath `
		-Force:( $PSCmdlet.MyInvocation.BoundParameters.Force.IsPresent -eq $true ) `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
};
