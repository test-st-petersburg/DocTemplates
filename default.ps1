#Requires -Version 5.0
#Requires -Modules psake

# task default -depends Build;

task Clean {
	if ( Test-Path -Path 'src' ) {
		Remove-Item -Path 'src' -Recurse -Force;
	};
}

task ? -Description "Helper to display task info" {
	Write-Documentation;
};
