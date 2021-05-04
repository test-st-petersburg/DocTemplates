# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

<#
	.Synopsis
		Creates a new file or updates the modified date of an existing file.
		See 'touch'.

	.Parameter Path
		The path of the file to create or update.
#>
[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
Param(
	[Parameter( Mandatory = $True, Position = 1 )]
	[System.String] $Path
)

if ( -not [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters( $Path ) ) {
	if ( -not ( Test-Path -Path $Path ) ) {
		New-Item -ItemType File -Path $Path `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true ) `
			-WhatIf:( $PSCmdlet.MyInvocation.BoundParameters.WhatIf.IsPresent -eq $true ) `
		| Out-Null;
	};
};
Set-ItemProperty -Path $Path -Name LastWriteTime -Value ( Get-Date ) `
	-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
	-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true ) `
	-WhatIf:( $PSCmdlet.MyInvocation.BoundParameters.WhatIf.IsPresent -eq $true ) `
| Out-Null;
