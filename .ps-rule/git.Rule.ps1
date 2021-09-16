Rule 'Git.Repo.Files' {
	Recommend '.gitattributes file must be exists'
	$Assert.FilePath($TargetObject, 'FullName', @( '.gitattributes' ));
}
