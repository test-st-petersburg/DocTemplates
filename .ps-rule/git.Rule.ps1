#Requires -Modules PSRule

# Synopsis: Check for recommended community files
Rule 'GitHub.Community' -Type 'PSRule.Data.RepositoryInfo' {
	$Assert.FilePath($TargetObject, 'FullName', @( '.gitattributes' ));
}
