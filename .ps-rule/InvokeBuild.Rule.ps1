Rule 'Invoke-Build.Config' -Type 'System.IO.DirectoryInfo' {
	Recommend 'Invoke-Build .build.ps1 file must be exists'
	$Assert.FilePath($TargetObject, 'FullName', @( '.build.ps1' ));
}
