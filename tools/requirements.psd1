@{
	'7Zip4Powershell' = @{
		DependencyType = 'PSGalleryModule'
		Target         = 'CurrentUser'
		Version        = 'latest'
	}
	'PSDeploy'        = @{
		DependencyType = 'PSGalleryModule'
		Target         = 'CurrentUser'
		Version        = 'latest'
	}
	'Saxon-HE'        = @{
		DependencyType = 'Nuget'
		Target         = './packages'
		Version        = '9.8.0'
	}
}
