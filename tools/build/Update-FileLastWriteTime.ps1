# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

<#
	.Synopsis
		Creates a new file or updates the modified date of an existing file.
		See 'touch'.
#>
[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true, DefaultParameterSetName = 'Path' )]
Param(
	[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $True, ParameterSetName = 'Path', ValueFromPipelineByPropertyName = $true )]
	[ValidateNotNullOrEmpty()]
	[SupportsWildcards()]
	[System.String[]]
	$Path,

	[Parameter( Mandatory = $True, Position = 0, ParameterSetName = 'LiteralPath', ValueFromPipelineByPropertyName = $true )]
	[Alias('PSPath')]
	[ValidateNotNullOrEmpty()]
	[System.String[]]
	$LiteralPath
)

switch ( $PSCmdlet.ParameterSetName )
{
	'Path'
	{
		$parameters = $PSCmdlet.MyInvocation.BoundParameters;
		$null = $parameters.Remove( 'Path' );
		$Path | Resolve-Path | ForEach-Object { & $PSCmdlet.MyInvocation.MyCommand -LiteralPath ( $_.Path ) @parameters };
	}
	'LiteralPath'
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
	}
}
