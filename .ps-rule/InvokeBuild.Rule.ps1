Rule 'Invoke-Build.Config' {
	Recommend 'Invoke-Build .build.ps1 file must be exists'
	$Assert.FilePath($TargetObject, 'FullName', @( '.build.ps1' ));
}
