Function Get-XSLTTransform {

	<#
	.Synopsis
		Возвращает исполняемый объект XSLT трансформации на базе Saxon HE.
	#>

	[CmdletBinding()]

	Param(
		# путь к файлу XSLT
		[Parameter( Mandatory = $True, Position = 0 )]
		[System.String]
		$LiteralPath
	)

	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

	$saxonPackage = Get-Package -Name 'Saxon-HE' -MinimumVersion 9.8 -MaximumVersion 9.999 `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	$saxonLibPath = Join-Path -Path ( Split-Path -Path ( $saxonPackage.Source ) -Parent ) `
		-ChildPath 'lib\net40\saxon9he-api.dll';
	Add-Type -Path $saxonLibPath `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

	try {
		Write-Verbose 'Создание SAX процессора.';
		$saxProcessor = New-Object Saxon.Api.Processor;
		Write-Verbose 'Создание SAX XSLT 3.0 компилятора.';
		$saxCompiler = $saxProcessor.NewXsltCompiler();
		Write-Verbose 'Компиляция XSLT.';
		try {
			$saxExecutable = $saxCompiler.Compile( $LiteralPath );
			foreach ( $Error in $saxCompiler.ErrorList ) {
				Write-Warning `
					-Message @"

$($Error.Message)
$( ( [System.Uri]$Error.ModuleUri ).LocalPath ):$($Error.LineNumber) знак:$($Error.ColumnNumber)
"@ `
					-WarningAction ( $PSCmdlet.MyInvocation.BoundParameters.WarningAction );
			};
		}
		catch {
			Write-Error -Message "Ошибок $( $saxCompiler.ErrorList.Count )" -ErrorAction Continue;
			foreach ( $Error in $saxCompiler.ErrorList ) {
				if ( $Error.isWarning ) {
					Write-Warning `
						-Message @"

$($Error.Message)
$( ( [System.Uri]$Error.ModuleUri ).LocalPath ):$($Error.LineNumber) знак:$($Error.ColumnNumber)
"@ `
						-WarningAction ( $PSCmdlet.MyInvocation.BoundParameters.WarningAction );
				}
				else {
					Write-Error `
						-Message @"

ERROR: $($Error.Message)
$( ( [System.Uri]$Error.ModuleUri ).LocalPath ):$($Error.LineNumber) знак:$($Error.ColumnNumber)
"@ `
						-Exception $Error `
						-ErrorAction Continue;
				};
			};
			throw;
		};
		$saxTransform = $saxExecutable.Load();
		$saxTransform.SchemaValidationMode = [Saxon.Api.SchemaValidationMode]::Preserve;
		# $saxTransform.RecoveryPolicy = [Saxon.Api.RecoveryPolicy]::DoNotRecover;
		return $saxTransform;
	}
	catch {
		Write-Error -ErrorRecord $_ `
			-ErrorAction ( $PSCmdlet.MyInvocation.BoundParameters.ErrorAction );
	};

}
