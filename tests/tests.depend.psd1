# Copyright 2020 Sergei S. Betke
@{
	Pester = @{
		DependencyType = 'PSGalleryModule';
		Version = '5.3.0';
		Source = 'PSGalleryModule';
		Target = 'CurrentUser';
	};

	# maven = @{
	# 	DependencyType = 'chocolatey';
	# 	Name = 'maven';
	# 	Target = 'CurrentUser';
	# };

	ODFValidator = @{
		DependencyType = 'Task';
		Target = '$DependencyPath\Prepare-ODFValidator.ps1';
		# DependsOn = 'maven';
	};
}
