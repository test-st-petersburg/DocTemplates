Rule 'GitVersion.Config' {
	Recommend 'GitVersion config file must be exists'
	$Assert.FilePath($TargetObject, 'FullName', @( 'GitVersion.yml' ));
}
