# Copyright 2020 Sergei S. Betke
@{
	Pester = @{
		DependencyType = 'PSGalleryModule';
		Version = '5.3.0';
		Source = 'PSGalleryModule';
		Target = 'CurrentUser';
	};

	# JRE = @{
	# 	DependencyType = 'chocolatey';
	# 	Name = 'OpenJDK';
	# };

	# maven = @{
	# 	DependencyType = 'chocolatey';
	# 	Name = 'maven';
	#	DependsOn = 'JRE';
	# };

	ODFValidator = @{
		DependencyType = 'Task';
		Target = '$DependencyPath\Prepare-ODFValidator.ps1';
		# DependsOn = 'maven';
	};
}
