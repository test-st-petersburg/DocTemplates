Rule 'GitVersion.Config' -Type 'PSRule.Data.RepositoryInfo' {
	Recommend 'GitVersion config file must be exists'
	$Assert.FilePath($TargetObject, 'FullName', @( 'GitVersion.yml' ));
}
