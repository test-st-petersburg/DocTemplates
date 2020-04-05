<#
	.SYNOPSIS
		Создаёт open office файлы из папки с xml файлами
#>

#Requires -Version 5.0
#Requires -Modules 7Zip4Powershell

[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
param(
	# путь к папке с xml файлами
	[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $true )]
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

begin {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	Import-Module 7Zip4Powershell;
}
process {
	if ( $PSCmdlet.ShouldProcess( $DestinationPath, "Create Open Office document from plain XML directory" ) ) {
		$TempZIPFileName = [System.IO.Path]::GetTempFileName() + '.zip';
		# по требованиям Open Office первым добавляем **без сжатия** файл mimetype
		Compress-7Zip -ArchiveFileName $TempZIPFileName -Path $Path -Filter 'mimetype' `
			-Format Zip `
			-CompressionLevel None `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		Get-ChildItem -Path $Path -File -Recurse -Exclude 'mimetype' `
		| Compress-7Zip -ArchiveFileName $TempZIPFileName -Append `
			-Format Zip `
			-CompressionLevel Normal -CompressionMethod Deflate `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		Move-Item -Path $TempZIPFileName `
			-Destination ( Join-Path -Path $DestinationPath -ChildPath ( ( Get-Item -Path $Path ).BaseName ) ) `
			-Force:( $PSCmdlet.MyInvocation.BoundParameters.Force.IsPresent -eq $true ) `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};
}
