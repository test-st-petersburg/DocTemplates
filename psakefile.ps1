#Requires -Version 5.0
#Requires -Modules psake

properties {
	$buildOutputPath = ".\template";
	$sourcePath = ".\src\template";
	$ottFiles = ( Get-ChildItem -Path $buildOutputPath -File -Filter '*.ott' );
	$sources = ( Get-ChildItem -Path $sourcePath -Directory );
};

# task default -depends Build;

task Clean -Description 'Clean source directory for selected or all .ott files' {
	Write-Host $sources;
	Push-Location;
	try {
		Set-Location $sourcePath;
		$sources | ForEach-Object {
			if ( Test-Path -Path $_ ) {
				Remove-Item -Path $_ -Recurse -Force;
			};
		};
	}
	finally {
		Pop-Location;
	};
};
