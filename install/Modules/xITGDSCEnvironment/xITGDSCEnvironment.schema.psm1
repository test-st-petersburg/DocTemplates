configuration ITGDSCEnvironment
{
	param
	(
		[string[]]$ComputerName = 'localhost'
	)

	Import-DscResource -ModuleName PSDesiredStateConfiguration
	Import-DscResource -ModuleName PackageManagement -ModuleVersion 1.3.1
	Import-DscResource -ModuleName xPowerShellExecutionPolicy
	Import-DscResource -ModuleName xWinRM

	Node $ComputerName
	{
		<#
		PackageManagementSource PSGallery {
			Ensure             = "Present"
			Name               = "PSGallery"
			ProviderName       = "PowerShellGet"
			SourceLocation     = "https://www.powershellgallery.com/api/v2/"
			InstallationPolicy = "Trusted"
		}
		#>

		PackageManagement cChoco
		{
			Ensure = "Present"
			Name = "cChoco"
			Source = "PSGallery"
			#    DependsOn = "[PackageManagementSource]PSGallery"
		}

		Service WinRMService
		{
			Name = "WinRM"
			Ensure = "Present"
			StartupType = "Automatic"
			State = "Running"
		}

		<#
		xWinRM WinRM {
			Ensure                   = "Present"
			Protocol                 = "HTTP"
			HTTPPort                 = "5985"
			Client_Basic             = "false"
			Client_Digest            = "false"
			Client_Kerberos          = "true"
			Client_Negotiate         = "true"
			Service_AllowUnencrypted = "false"
		}
		#>

		xPowerShellExecutionPolicy PowerShellExecutionPolicy
		{
			ExecutionPolicy = "Unrestricted"
		}
	}
}
