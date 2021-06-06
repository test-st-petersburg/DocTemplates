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

	# путь к папке с библиотеками макросов
	[System.String]
	$DestinationLibrariesPath = ( property DestinationLibrariesPath (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $DestinationPath -ChildPath 'basic' )
			)
		) ),

	# путь к папке с генерируемыми файлами, используемыми только для выполнения других задач
	[System.String]
	$TempPath = ( property TempPath (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $ProjectRoot -ChildPath 'tmp' )
			)
		) ),

	# путь к папке с контейнерами библиотек макросов
	[System.String]
	$DestinationLibContainersPath = ( property DestinationLibContainersPath (
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
				( Join-Path -Path $TempPath -ChildPath 'basic' )
			)
		) ),

	# путь к папке с исходными файлами
	[System.String]
	$SourcePath = ( property SourcePath (
			( Resolve-Path -Path `
				( Join-Path -Path $ProjectRoot -ChildPath 'src' )
			).Path
		) ),

	# путь к папке с исходными файлами библиотек макросов
	[System.String]
	$SourceLibrariesPath = ( property SourceLibrariesPath (
			( Resolve-Path -Path `
				( Join-Path -Path $SourcePath -ChildPath 'basic' )
			).Path
		) ),

	# пути к папкам с "исходными" файлами библиотек макросов
	[System.String[]]
	$SourceLibrariesFolder = ( property SourceLibrariesFolder @(
			$SourceLibrariesPath | Where-Object { Test-Path -Path $_ } |
			Get-ChildItem -Directory | Select-Object -ExpandProperty FullName
		) ),

	# версия шаблонов и файлов
	[System.String]
	$Version
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

# Synopsis: Удаляет каталоги с временными и собранными файлами
task Clean {
	remove $DestinationLibrariesPath, $DestinationLibContainersPath;
};

#region сборка библиотек макросов

$BuildLibrariesTasks = @();
$BuildLibContainersTasks = @();
foreach ( $sourceLibFolder in $SourceLibrariesFolder )
{
	$LibName = Split-Path -Path ( $sourceLibFolder ) -Leaf;
	$BuildTaskName = "BuildLib-$LibName";
	$BuildLibrariesTasks += $BuildTaskName;
	$prerequisites = @( Get-ChildItem -Path $sourceLibFolder -File -Recurse );
	$target = Join-Path -Path $DestinationLibrariesPath -ChildPath $LibName;
	$scriptsLibFile = Join-Path -Path $target -ChildPath 'script.xlb';
	$targetFiles = @(
		$prerequisites | Where-Object { $_.Extension -eq '.bas' } `
		| ForEach-Object { [System.IO.Path]::ChangeExtension( $_.FullName, '.xba' ) } `
		| ForEach-Object { $_.Replace( $sourceLibFolder, $target ) }
	);
	$targetFiles = @( $scriptsLibFile ) + $targetFiles;

	task $BuildTaskName `
		-Inputs $prerequisites `
		-Outputs $targetFiles `
	{
		$SourceLibFolder = Split-Path -Path $Inputs[0] -Parent;

		$SourceLibFolder | .\..\..\tools\docs\Build-OOMacroLib.ps1 -DestinationPath $DestinationLibrariesPath -Force `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};

	$BuildLibContainerTaskName = "BuildLibContainer-$LibName";
	$BuildLibContainersTasks += $BuildLibContainerTaskName;
	# $prerequisites = @( Get-ChildItem -Path $sourceLibFolder -File -Recurse );

	$targetContainer = Join-Path -Path $DestinationLibContainersPath -ChildPath $LibName;
	$targetContainerBasic = Join-Path -Path $targetContainer -ChildPath 'Basic';
	$targetContainerScriptsFile = Join-Path -Path $targetContainerBasic -ChildPath 'script-lc.xml';
	$targetContainerBasicLib = Join-Path -Path $targetContainerBasic -ChildPath $LibName;
	$targetContainerScriptsLibFile = Join-Path -Path $targetContainerBasicLib -ChildPath 'script-lb.xml';
	$targetContainerFiles = @(
		$prerequisites | Where-Object { $_.Extension -eq '.bas' } `
		| ForEach-Object { [System.IO.Path]::ChangeExtension( $_.FullName, '.xml' ) } `
		| ForEach-Object { $_.Replace( $sourceLibFolder, $targetContainerBasicLib ) }
	);
	$targetContainerMeta = Join-Path -Path $targetContainer -ChildPath 'META-INF';
	$targetContainerManifest = Join-Path -Path $targetContainerMeta -ChildPath 'manifest.xml';

	task $BuildLibContainerTaskName `
		-Inputs $targetFiles `
		-Outputs ( ( $targetContainerManifest, $targetContainerScriptsLibFile, $targetContainerScriptsFile ) `
			+ $targetContainerFiles	) `
		-Job $BuildTaskName, `
	{
		$LibFolder = Split-Path -Path $Inputs[0] -Parent;

		$LibFolder | .\..\..\tools\docs\Build-OOMacroLibContainer.ps1 -DestinationPath $DestinationLibContainersPath -Force `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};
};

# Synopsis: Создаёт библиотеки макросов Open Office
task BuildLibs $BuildLibrariesTasks;

# Synopsis: Создаёт контейнеры библиотек макросов Open Office для последующей интеграции в шаблоны и документы
task BuildLibContainers $BuildLibContainersTasks;

#endregion

task Build BuildLibs, BuildLibContainers;

task . Build;
