# You can see the predefined Pester settings here:
# https://pester.dev/docs/commands/Invoke-Pester
@{
	Run = @{
		Exit = $true;
	};
	Debug = @{
		ShowFullErrors = $false;
	};
	Filter = @{
		Tag = 'ODFValidator';
	};
	Output = @{
		Verbosity = 'Detailed';
	};
}
