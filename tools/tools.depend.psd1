# Copyright 2020 Sergei S. Betke
@{
	nuget = @{
		DependencyType = 'FileDownload';
		Name = 'nuget.exe';
		Source = 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe';
		Target = '$DependencyPath\nuget.exe';
	};
}
