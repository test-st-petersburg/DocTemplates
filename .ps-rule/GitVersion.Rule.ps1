#Requires -Modules PSRule

Rule 'GitHub.Community' -Type 'PSRule.Data.RepositoryInfo' {
	$Assert.FilePath($TargetObject, 'FullName', @( 'GitVersion.yml' ));
}
