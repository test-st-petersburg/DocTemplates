Rule 'Git.Repo.Files' -Type 'System.IO.DirectoryInfo', 'PSRule.Data.RepositoryInfo' {
	Recommend '.gitattributes file must be exists'
	$Assert.FilePath($TargetObject, 'FullName', @( '.gitattributes' ));
}
