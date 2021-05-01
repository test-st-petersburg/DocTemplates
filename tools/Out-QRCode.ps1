# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

<#
	.SYNOPSIS
		Create QR code file

	.DESCRIPTION
		Create QR code with selected data
#>
[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
Param(
	# Данные для QR
	[Parameter( Mandatory = $True, ValueFromPipeline = $True )]
	[System.String]
	$Input,

	[Parameter( Mandatory = $True )]
	[System.String]
	$FilePath,

	[Parameter( Mandatory = $False )]
	[System.Int16]
	$Width = 1,

	[Switch]
	$Force
)

begin
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	$LibPath = Join-Path -Path $PSScriptRoot -ChildPath 'packages\QRCoder.1.4.1\lib\net40\QRCoder.dll';
	Add-Type -Path $LibPath `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

	[QRCoder.QRCodeGenerator] $QRGenerator = New-Object -TypeName QRCoder.QRCodeGenerator;
}
process
{
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	[QRCoder.QRCodeData] $QRCodeData = $QRGenerator.CreateQrCode($Input, [QRCoder.QRCodeGenerator+ECCLevel]::Q);
	$QRCode = New-Object -TypeName QRCoder.PngByteQRCode -ArgumentList $QRCodeData;
	$ImageData = $QRCode.GetGraphic( $Width );

	[System.String] $FullFilePath;
	if ( [System.IO.Path]::IsPathRooted( $FilePath ) )
	{
		$FullFilePath = $FilePath;
	}
	else
	{
		$FullFilePath = Join-Path -Path ( ( Get-Location -PSProvider FileSystem ).Path ) -ChildPath $FilePath;
	};
	if ( $PSCmdlet.ShouldProcess( $FullFilePath, 'Write QRCode to file' ) )
	{
		[System.IO.File]::WriteAllBytes( $FullFilePath, $ImageData );
	};
}
