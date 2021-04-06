#Requires -Modules PSRule

Rule 'GitHub.Community' -Type 'PSRule.Data.RepositoryInfo' {
	$Assert.FilePath($TargetObject, 'FullName', @( '.editorconfig' ));
	$Assert.FilePath($TargetObject, 'FullName', @( '.markdownlint.json' ));
	$Assert.FilePath($TargetObject, 'FullName', @( 'commitlint.config.js' ));
}
