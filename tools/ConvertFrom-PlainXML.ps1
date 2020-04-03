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

function Use-Object {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[AllowEmptyString()]
		[AllowEmptyCollection()]
		[AllowNull()]
		[Object]
		$InputObject,

		[Parameter(Mandatory = $true)]
		[scriptblock]
		$ScriptBlock
	)

	try	{
		. $ScriptBlock;
	}
 finally {
		if ($null -ne $InputObject -and $InputObject -is [System.IDisposable]) {
			$InputObject.Dispose();
		};
	};
}

if ( $PSCmdlet.ShouldProcess( $DestinationPath, "Create Open Office document from plain XML directory" ) ) {
	Add-Type -AssemblyName System.IO;
	Add-Type -AssemblyName System.IO.Compression;
	Add-Type -AssemblyName System.IO.Compression.FileSystem;

	$TempZIPFileName = [System.IO.Path]::GetTempFileName() + '.zip';

	Write-Verbose "Create and open zip file $TempZIPFileName";
	Use-Object ( $zipFileStream = New-Object System.IO.FileStream( $TempZIPFileName, [System.IO.FileMode]::Create ) ) {
		Use-Object ( $archive = New-Object System.IO.Compression.ZipArchive( $zipFileStream, [System.IO.Compression.ZipArchiveMode]::Create ) ) {
			Push-Location;
			Set-Location $Path;
			# по требованиям Open Office первым добавляем **без сжатия** файл mimetype
			@( Get-Item -Path 'mimetype' ) +
			@( Get-ChildItem -Path . -File -Recurse -Exclude 'mimetype' ) `
				| ForEach-Object {
				$entryPath = ( Resolve-Path -Path $_ -Relative ).Substring( 2 );
				if ( $entryPath -in , 'mimetype' ) {
					$compressionLevel = [System.IO.Compression.CompressionLevel]::NoCompression;
				}
				else {
					$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal;
				};
				Write-Debug "Create archive entry $entryPath with compression level $compressionLevel";
				$entry = $archive.CreateEntry( $entryPath, $compressionLevel );
				# $entry.ExternalAttributes = 0;
				Use-Object ( $entryStream = $entry.Open() ) {
					Write-Debug "Open source file $_.FullName";
					Use-Object ( $fileStream = [System.IO.File]::Open( $_.FullName, [System.IO.FileMode]::Open ) ) {
						Write-Verbose "Add file $entryPath to archive $TempZIPFileName with compression level $compressionLevel";
						$fileStream.CopyTo( $entryStream );
					};
				};
			};

			# $mimetypeEntry = $archive.CreateEntry( 'mimetype', [System.IO.Compression.CompressionLevel]::NoCompression );
			# $mimetypeEntry.ExternalAttributes = 0;
			# Use-Object ( $entryStream = $mimetypeEntry.Open() ) {
			# 	Use-Object ( $fileStream = [System.IO.File]::Open( ( Join-Path -Path $Path -ChildPath 'mimetype' ), [System.IO.FileMode]::Open ) ) {
			# 		$fileStream.CopyTo( $entryStream );
			# 	};
			# };
			# [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile( $archive,
			# 	( Join-Path -Path $Path -ChildPath 'mimetype' ),
			# 	'mimetype',
			# 	[System.IO.Compression.CompressionLevel]::NoCompression
			# );

			Pop-Location;
		};
	};

	# Compress-Archive -Path ( Join-Path -Path $Path -ChildPath 'mimetype' ) `
	# 	-DestinationPath $TempZIPFileName  `
	# 	-CompressionLevel NoCompression `
	# 	-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
	# 	-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	# Get-ChildItem -Path $Path -Exclude 'mimetype' `
	# | Compress-Archive `
	# 	-DestinationPath $TempZIPFileName `
	# 	-Update `
	# 	-CompressionLevel Fastest `
	# 	-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
	# 	-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	Move-Item -Path $TempZIPFileName -Destination $DestinationPath `
		-Force:( $PSCmdlet.MyInvocation.BoundParameters.Force.IsPresent -eq $true ) `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
};
