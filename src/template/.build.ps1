#Requires -Version 5.0
#Requires -Modules InvokeBuild

param(
	# путь к корневой папке проекта
	[System.String]
	$ProjectRoot = ( property ProjectRoot (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $PSScriptRoot -ChildPath '.\..\..' )
			)
		) ),

	# путь к папке с генерируемыми файлами
	[System.String]
	$DestinationPath = ( property DestinationPath (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $ProjectRoot -ChildPath 'output' )
			)
		) ),

	# путь к папке с .ott файлами
	[System.String]
	$DestinationTemplatesPath = ( property DestinationTemplatesPath (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $DestinationPath -ChildPath 'template' )
			)
		) ),

	# имя .ott шаблона
	[System.String]
	$TemplatesFilter = ( property TemplatesFilter '*.ott' ),

	# путь к папке с генерируемыми файлами, используемыми только для выполнения других задач
	[System.String]
	$TempPath = ( property TempPath (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $ProjectRoot -ChildPath 'tmp' )
			)
		) ),

	# путь к папке временного хранения препроцессированных XML файлов перед сборкой документов и шаблонов
	[System.String]
	$PreprocessedTemplatesPath = ( property PreprocessedTemplatesPath (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $TempPath -ChildPath 'template' )
			)
		) ),

	# путь к папке с исходными файлами
	[System.String]
	$SourcePath = ( property SourcePath (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $ProjectRoot -ChildPath 'src' )
			)
		) ),

	# путь к папке с xml папками .ott файлов
	[System.String]
	$SourceTemplatesPath = ( property SourceTemplatesPath (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $SourcePath -ChildPath 'template' )
			)
		) ),

	# пути к папкам с xml файлами .ott файлов
	[System.String[]]
	$SourceTemplatesFolder = ( property SourceTemplatesFolder @(
			$SourceTemplatesPath | Where-Object { Test-Path -Path $_ } |
			Get-ChildItem -Directory -Filter $TemplatesFilter | Select-Object -ExpandProperty FullName
		) ),

	# состояние окна Open Office при открытии документа
	# https://docs.microsoft.com/en-us/windows/win32/shell/shell-shellexecute
	# 0  Open the application with a hidden window.
	# 1  Open the application with a normal window. If the window is minimized or maximized, the system restores it to its original size and position.
	# 2  Open the application with a minimized window.
	# 3  Open the application with a maximized window.
	# 4  Open the application with its window at its most recent size and position. The active window remains active.
	# 5  Open the application with its window at its current size and position.
	# 7  Open the application with a minimized window. The active window remains active.
	# 10 Open the application with its window in the default state specified by the application.
	[System.Int16]
	$OOWindowState = ( property OOWindowState 10 ),

	# версия шаблонов и файлов
	[System.String]
	$Version
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

use '.\..\..\tools\docs' Build-OODocument.ps1;
use '.\..\..\tools\build' Update-FileLastWriteTime.ps1;

[System.String] $MarkerFileName = '.dirstate';

# Synopsis: Удаляет каталоги с временными файлами, собранными файлами шаблонов
task Clean {
	remove $DestinationTemplatesPath, $PreprocessedTemplatesPath;
};

$BuildTemplatesTasks = @();
$BuildAndOpenTemplatesTasks = @();
foreach ( $documentXMLFolder in $SourceTemplatesFolder )
{
	$documentName = $( Split-Path -Path ( $DocumentXMLFolder ) -Leaf );
	$BuildTaskName = "Build-$documentName";
	$BuildTemplatesTasks += $BuildTaskName;
	$BuildAndOpenTaskName = "BuildAndOpen-$documentName";
	$BuildAndOpenTemplatesTasks += $BuildAndOpenTaskName;
	$prerequisites = @( Get-ChildItem -Path $documentXMLFolder -File -Recurse -Exclude $MarkerFileName );
	$target = Join-Path -Path $DestinationTemplatesPath -ChildPath $documentName;
	$marker = Join-Path -Path $documentXMLFolder -ChildPath $MarkerFileName;

	# TODO: Restore BuildLibs, BuildQRCodes
	task $BuildTaskName -Inputs $prerequisites -Outputs @( $target, $marker ) -Job {
		$localDestinationFile = $Outputs[0];
		$marker = $Outputs[1];
		if ( Test-Path -Path $marker )
		{
			Remove-Item -Path $marker `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};
		$localXMLFolder = @( Join-Path -Path $SourceTemplatesPath -ChildPath ( Split-Path -Path $localDestinationFile -Leaf ) );
		$localXMLFolder | Build-OODocument.ps1 -DestinationPath $DestinationTemplatesPath -Force `
			-TempPath $PreprocessedTemplatesPath `
			-Version $Version `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		Update-FileLastWriteTime.ps1 -Path $marker `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};

	task $BuildAndOpenTaskName -Inputs $prerequisites -Outputs @( $target, $marker ) -Job $BuildTaskName, {
		$localDestinationFile = $Outputs[0];
		$Shell = New-Object -Com 'Shell.Application';
		$localDestinationFile | Get-Item | ForEach-Object {
			$verb = 'open';
			if ( $PSCmdlet.ShouldProcess( $_.FullName, $verb ) )
			{
				$Shell.ShellExecute( $_.FullName, $null, $_.Directory.FullName, $verb, $OOWindowState );
			};
		};
	};
};

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build)
task BuildTemplates $BuildTemplatesTasks;

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build) и открывает их
task BuildAndOpenTemplates $BuildAndOpenTemplatesTasks;

task Build BuildTemplates;

task BuildAndOpen BuildAndOpenTemplates;

task . Build;
