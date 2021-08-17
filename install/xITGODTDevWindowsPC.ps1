#Requires -Version 5.0
#Requires -Modules PSDesiredStateConfiguration
#Requires -Modules cChoco
#Requires -Modules xComputerManagement
#Requires -Modules ComputerManagementDsc
#Requires -Modules xPendingReboot
#Requires -Modules xDownloadFile

configuration xITGODTDevWindowsPC
{
	param
	(
		[string[]] $ComputerName = 'localhost'
	)

	Import-DscResource -ModuleName PackageManagement -ModuleVersion 1.3.1
	Import-DscResource -ModuleName PSDesiredStateConfiguration
	Import-DscResource -ModuleName cChoco
	Import-DscResource -ModuleName xComputerManagement
	Import-DSCResource -ModuleName xPendingReboot
	Import-DSCResource -ModuleName xDownloadFile
	Import-DSCResource -ModuleName ComputerManagementDsc
	Import-DscResource -ModuleName PowerShellModule -Name PSModuleResource

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

		cChocoPackageInstaller LibreOffice
		{
			Name = 'libreoffice-still'
			DependsOn = @('[cChocoInstaller]choco')
		}

		cChocoPackageInstaller GitVersion
		{
			Name = 'gitversion.portable'
			DependsOn = @('[cChocoInstaller]choco')
		}

		PSModuleResource 7Zip4Powershell
		{
			Module_Name = '7Zip4Powershell'
		}

		PSModuleResource InvokeBuild
		{
			Module_Name = 'InvokeBuild'
		}

		PSModuleResource PowerShellForGitHub
		{
			Module_Name = 'PowerShellForGitHub'
		}

		PSModuleResource Pester
		{
			Module_Name = 'Pester'
		}

		PackageManagement SaxonHE
		{
			Ensure = 'Present'
			Name = 'Saxon-HE'
			Source = 'NuGet'
			MinimumVersion = '9.8'
			MaximumVersion = '9.8.999'
		}

		PackageManagement QRCoder
		{
			Ensure = 'Present'
			Name = 'QRCoder'
			Source = 'NuGet'
		}

	}
}
