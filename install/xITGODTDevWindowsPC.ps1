#Requires -Version 5.0
#Requires -Modules PSDesiredStateConfiguration
#Requires -Modules cChoco
#Requires -Modules xComputerManagement
#Requires -Modules ComputerManagementDsc
#Requires -Modules xPendingReboot
#Requires -Modules xDownloadFile

configuration ITGNetworkManagementWindowsPC
{
	param
	(
		[string[]] $ComputerName = 'localhost'
	)

	Import-DscResource -ModuleName PSDesiredStateConfiguration
	Import-DscResource -ModuleName cChoco
	Import-DscResource -ModuleName xComputerManagement
	Import-DSCResource -ModuleName xPendingReboot
	Import-DSCResource -ModuleName xDownloadFile
	Import-DSCResource -ModuleName ComputerManagementDsc

	Node $ComputerName
	{

		cChocoInstaller choco
		{
			InstallDir = "${env:SystemDrive}\choco"
		}

		Environment chocolatelyInstall
		{
			Name = 'chocolatelyInstall'
			value = "${env:SystemDrive}\choco\bin"
			DependsOn = @('[cChocoInstaller]choco')
		}

		cChocoPackageInstaller VSCode
		{
			Name = 'vscode'
			DependsOn = @('[cChocoInstaller]choco')
		}

		cChocoPackageInstaller git
		{
			Name = 'git.install'
			DependsOn = @('[cChocoInstaller]choco')
		}

		cChocoPackageInstaller NodeJS
		{
			Name = 'nodejs'
			DependsOn = @('[cChocoInstaller]choco')
		}

	}
}
