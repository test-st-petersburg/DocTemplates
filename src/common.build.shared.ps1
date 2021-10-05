# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

Set-StrictMode -Version Latest;

[System.String] $MarkerFileName = '.dirstate';

if ( -not ( Test-Path variable:RepoRootPath ) -or ( [System.String]::IsNullOrEmpty( $RepoRootPath ) ) )
{
	[System.String] $RepoRootPath =	( Resolve-Path -Path $PSScriptRoot/../.. ).Path;
};

[System.String] $ToolsPath = ( Resolve-Path -Path $RepoRootPath/tools ).Path;
[System.String] $BuildToolsPath = ( Resolve-Path -Path $ToolsPath/build ).Path;
[System.String] $UpdateFileLastWriteTimePath = ( Resolve-Path -Path $BuildToolsPath/Update-FileLastWriteTime.ps1 ).Path;
[System.String] $DocsToolsPath = ( Resolve-Path -Path $ToolsPath/docs ).Path;
[System.String] $BuildOODocumentPath = ( Resolve-Path -Path $DocsToolsPath/Build-OODocument.ps1 ).Path;


# состояние окна приложения при открытии документа
# https://docs.microsoft.com/en-us/windows/win32/shell/shell-shellexecute
# 0  Open the application with a hidden window.
# 1  Open the application with a normal window. If the window is minimized or maximized, the system restores it to its original size and position.
# 2  Open the application with a minimized window.
# 3  Open the application with a maximized window.
# 4  Open the application with its window at its most recent size and position. The active window remains active.
# 5  Open the application with its window at its current size and position.
# 7  Open the application with a minimized window. The active window remains active.
# 10 Open the application with its window in the default state specified by the application.
[System.Int16] $WindowState = 10;

$JobOpenFile = {
	$filePath = $Outputs[0];
	$Shell = New-Object -Com 'Shell.Application';
	$filePath | Get-Item | ForEach-Object {
		$verb = 'open';
		if ( $PSCmdlet.ShouldProcess( $_.FullName, $verb ) )
		{
			$Shell.ShellExecute( $_.FullName, $null, $_.Directory.FullName, $verb, $WindowState );
		};
	};
};
