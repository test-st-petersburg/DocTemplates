# Copyright 2020 Sergei S. Betke
@{
	InvokeBuild = @{
		DependencyType = 'PSGalleryModule';
		Version = '5.5.1';
		Source = 'PSGalleryModule';
		Target = 'CurrentUser';
	};

	PowerShellForGitHub = @{
		DependencyType = 'PSGalleryModule';
		Version = '0.16.0';
		Source = 'PSGalleryModule';
		Target = 'CurrentUser';
	};
}
