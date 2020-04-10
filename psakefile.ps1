#Requires -Version 5.0
#Requires -Modules psake

properties {
	$buildOutputPath = ".\template";
	$sourcePath = ".\src\template";
	$ottFiles = ( Get-ChildItem -Path $buildOutputPath -File -Filter '*.ott' ) | Resolve-Path -Relative;
	$sources = ( Get-ChildItem -Path $sourcePath -Directory ) | Resolve-Path -Relative;
};

# task default -depends Build;

task Clean -Description 'Clean source directory for selected or all .ott files' {
	$sources | ForEach-Object {
		if ( Test-Path -Path $_ ) {
			Remove-Item -Path $_ -Recurse -Force;
		};
	};
};

task Build -Description 'Build .ott files from source XML files' {
	$sources | ForEach-Object {
	};
};
