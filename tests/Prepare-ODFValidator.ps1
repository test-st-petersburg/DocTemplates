#Requires -Version 5.0

[System.String] $ODFValidatorPath = ( Join-Path -Path $PSScriptRoot -ChildPath 'java/dependency' );
try
{
	Push-Location -Path $PSScriptRoot;
	. mvn dependency:copy-dependencies;
}
finally
{
	Pop-Location;
};
[System.String] $ODFValidatorJarPath = ( Get-ChildItem -LiteralPath $ODFValidatorPath -Filter 'ODFValidator-*.jar' -File )[0].FullName;
