# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

<#
	.Synopsis
		Creates a new file or updates the modified date of an existing file.
		See 'touch'.
#>
[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true, DefaultParameterSetName = 'Path' )]
Param(
	[Parameter( Mandatory = $True, Position = 1, ParameterSetName = 'Path' )]
	[System.String[]] $Path,

	[Parameter( Mandatory = $True, ParameterSetName = 'LiteralPath' )]
	[System.String[]] $LiteralPath
)

if ( $PSCmdlet.ParameterSetName -eq 'Path' )
{
	$parameters = $PSCmdlet.MyInvocation.BoundParameters;
	$null = $parameters.Remove( 'Path' );
	$Path | ForEach-Object {
		$FilePath = ( Resolve-Path -Path $_ ).Path;
		& $PSCmdlet.MyInvocation.MyCommand -LiteralPath $FilePath @parameters;
	};
}
elseif ( $PSCmdlet.ParameterSetName -eq 'LiteralPath' )
{
	foreach ( $FilePath in $LiteralPath )
	{
		if ( -not ( Test-Path -LiteralPath $FilePath ) )
		{
			$null = New-Item -ItemType File -Path $FilePath `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true ) `
				-WhatIf:( $PSCmdlet.MyInvocation.BoundParameters['WhatIf'] -eq $true );
		};
		$null = Set-ItemProperty -LiteralPath $FilePath -Name LastWriteTime -Value ( Get-Date ) `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true ) `
			-WhatIf:( $PSCmdlet.MyInvocation.BoundParameters['WhatIf'] -eq $true );
	};
};
