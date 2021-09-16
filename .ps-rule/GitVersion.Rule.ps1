Rule 'GitVersion.Config' -Type 'System.IO.DirectoryInfo' {
	Recommend 'GitVersion config file must be exists'
	$Assert.FilePath($TargetObject, 'FullName', @( 'GitVersion.yml' ));
}
