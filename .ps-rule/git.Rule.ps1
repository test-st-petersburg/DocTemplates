Rule 'Git.Repo.Files' -Type 'PSRule.Data.RepositoryInfo' {
	Recommend '.gitattributes file must be exists'
	$Assert.FilePath($TargetObject, 'FullName', @( '.gitattributes' ));
}
