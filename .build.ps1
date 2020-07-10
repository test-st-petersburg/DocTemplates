#Requires -Version 5.0
#Requires -Modules InvokeBuild

param(
	# путь к папке с генерируемыми файлами
	[System.String]
	$DestinationPath = ( property DestinationPath ( Join-Path -Path ( ( Get-Location ).Path ) -ChildPath 'output' ) ),

	# путь к папке с .ott файлами
	[System.String]
	$DestinationTemplatesPath = ( property DestinationTemplatesPath (
			Join-Path -Path $DestinationPath -ChildPath 'template'
		) ),

	# имя .ott шаблона
	[System.String]
	$TemplatesFilter = ( property TemplatesFilter '*.ott' ),

	# путь к .ott файлу
	[System.String[]]
	$DestinationTemplateFile = ( property DestinationTemplateFile @(
			$DestinationTemplatesPath | Where-Object { Test-Path -Path $_ } |
				Get-ChildItem -Filter $TemplatesFilter | Select-Object -ExpandProperty FullName
		) ),

	# путь к папке с библиотеками макросов
	[System.String]
	$DestinationLibrariesPath = ( property DestinationLibrariesPath (
			Join-Path -Path $DestinationPath -ChildPath 'basic'
		) ),

	# путь к папке с генерируемыми файлами, используемыми только для выполнения других задач
	[System.String]
	$TempPath = ( property TempPath ( Join-Path -Path ( ( Get-Location ).Path ) -ChildPath 'tmp' ) ),

	# путь к папке с контейнерами библиотек макросов
	[System.String]
	$DestinationLibContainersPath = ( property DestinationLibContainersPath (
			Join-Path -Path $TempPath -ChildPath 'basic'
		) ),

	# путь к папке временного хранения препроцессированных XML файлов перед сборкой документов и шаблонов
	[System.String]
	$PreprocessedTemplatesPath = ( property PreprocessedTemplatesPath (
			Join-Path -Path $TempPath -ChildPath 'template'
		) ),

	# путь к папке с исходными файлами
	[System.String]
	$SourcePath = ( property SourcePath ( ( Resolve-Path -Path '.\src' ).Path ) ),

	# путь к папке с xml папками .ott файлов
	[System.String]
	$SourceTemplatesPath = ( property SourceTemplatesPath (
			Join-Path -Path $SourcePath -ChildPath 'template'
		) ),

	# пути к папкам с xml файлами .ott файлов
	[System.String[]]
	$SourceTemplatesFolder = ( property SourceTemplatesFolder @(
			$SourceTemplatesPath | Where-Object { Test-Path -Path $_ } |
				Get-ChildItem -Directory -Filter $TemplatesFilter.ott | Select-Object -ExpandProperty FullName
		) ),

	# путь к папке с исходными файлами библиотек макросов
	[System.String]
	$SourceLibrariesPath = ( property SourceLibrariesPath (
			Join-Path -Path $SourcePath -ChildPath 'basic'
		) ),

	# пути к папкам с "исходными" файлами библиотек макросов
	[System.String[]]
	$SourceLibrariesFolder = ( property SourceLibrariesFolder @(
			$SourceLibrariesPath | Where-Object { Test-Path -Path $_ } |
				Get-ChildItem -Directory | Select-Object -ExpandProperty FullName
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
	$OOWindowState = ( property OOWindowState 10 )
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

<#
	.Synopsis
		Creates a new file or updates the modified date of an existing file.
		See 'touch'.

	.Parameter Path
		The path of the file to create or update.
#>
Function Update-FileLastWriteTime {
	[CmdletBinding( ConfirmImpact = 'Low', SupportsShouldProcess = $true )]
	Param(
		[Parameter( Mandatory = $True, Position = 1 )]
		[System.String] $Path
	)

	if ( -not [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters( $Path ) ) {
		if ( -not ( Test-Path -Path $Path ) ) {
			New-Item -ItemType File -Path $Path `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true ) `
				-WhatIf:( $PSCmdlet.MyInvocation.BoundParameters.WhatIf.IsPresent -eq $true ) `
				| Out-Null;
		};
	};
	Set-ItemProperty -Path $Path -Name LastWriteTime -Value ( Get-Date ) `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true ) `
		-WhatIf:( $PSCmdlet.MyInvocation.BoundParameters.WhatIf.IsPresent -eq $true ) `
		| Out-Null;
}

if ( -not ( Test-Path -Path $DestinationTemplatesPath ) ) {
	New-Item -Path $DestinationTemplatesPath -ItemType Directory `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true ) `
		| Out-Null;
};

[System.String] $MarkerFileName = '.dirstate';

# Synopsis: Удаляет каталоги с временными файлами, собранными файлами документов и их шаблонов
task Clean {
	$DestinationPath, $TempPath | Where-Object { Test-Path -Path $_ } | Remove-Item -Recurse -Force;
};

# Synopsis: Удаляет каталоги с XML файлами
task RemoveSources {
	$SourceTemplatesFolder | Where-Object { $_ } | Where-Object { Test-Path -Path $_ } | Remove-Item -Recurse -Force;
};

# Synopsis: Преобразовывает Open Office файлы в папки с XML файлами
task Unpack RemoveSources, {
	$DestinationTemplateFile | .\tools\ConvertTo-PlainXML.ps1 -DestinationPath $SourceTemplatesPath `
		-Indented `
		-WarningAction Continue `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
};

# Synopsis: Оптимизирует XML файлы Open Office
task OptimizeXML {
	$SourceTemplatesFolder | .\tools\Optimize-PlainXML.ps1 `
		-WarningAction Continue `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
};

task UnpackAndOptimize Unpack, OptimizeXML;

$OOFilesUnpackTasks = @();
foreach ( $OOFile in $DestinationTemplateFile ) {
	$documentName = $( Split-Path -Path ( $OOFile ) -Leaf );
	$OOUnpackTaskName = "UnpackAndOptimize-$documentName";
	$OOFilesUnpackTasks += $OOUnpackTaskName;
	$targetFolder = Join-Path -Path $SourceTemplatesPath -ChildPath $documentName;
	$target = Join-Path -Path $targetFolder -ChildPath 'META-INF/manifest.xml';
	$marker = Join-Path -Path $targetFolder -ChildPath $MarkerFileName;

	task $OOUnpackTaskName `
		-Inputs @( $OOFile ) `
		-Outputs @( $marker ) `
 {
		$localOOFile = $Inputs[0];
		$documentName = $( Split-Path -Path ( $localOOFile ) -Leaf );
		$localOOFile | .\tools\ConvertTo-PlainXML.ps1 -DestinationPath $SourceTemplatesPath `
			-Indented `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

		$localOOXMLFolder = Join-Path -Path $SourceTemplatesPath -ChildPath $documentName;
		$localOOXMLFolder | .\tools\Optimize-PlainXML.ps1 `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};
};

# Synopsis: Распаковывает только изменённые файлы
task UnpackAndOptimizeModified $OOFilesUnpackTasks;

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build)
$version = gitversion /output json /showvariable SemVer

$BuildLibrariesTasks = @();
$BuildLibContainersTasks = @();
foreach ( $sourceLibFolder in $SourceLibrariesFolder ) {
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

		$SourceLibFolder | .\tools\Build-OOMacroLib.ps1 -DestinationPath $DestinationLibrariesPath -Force `
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

		$LibFolder | .\tools\Build-OOMacroLibContainer.ps1 -DestinationPath $DestinationLibContainersPath -Force `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};
};

# Synopsis: Создаёт библиотеки макросов Open Office
task BuildLibs $BuildLibrariesTasks;

# Synopsis: Создаёт контейнеры библиотек макросов Open Office для последующей интеграции в шаблоны и документы
task BuildLibContainers $BuildLibContainersTasks;

$BuildTasks = @();
$BuildAndOpenTasks = @();
foreach ( $documentXMLFolder in $SourceTemplatesFolder ) {
	$documentName = $( Split-Path -Path ( $DocumentXMLFolder ) -Leaf );
	$BuildTaskName = "Build-$documentName";
	$BuildTasks += $BuildTaskName;
	$BuildAndOpenTaskName = "BuildAndOpen-$documentName";
	$BuildAndOpenTasks += $BuildAndOpenTaskName;
	$prerequisites = @( Get-ChildItem -Path $documentXMLFolder -File -Recurse -Exclude $MarkerFileName );
	$target = Join-Path -Path $DestinationTemplatesPath -ChildPath $documentName;
	$marker = Join-Path -Path $documentXMLFolder -ChildPath $MarkerFileName;

	task $BuildTaskName `
		-Inputs $prerequisites `
		-Outputs @( $target, $marker ) `
	{
		$localDestinationFile = $Outputs[0];
		$marker = $Outputs[1];
		if ( Test-Path -Path $marker ) {
			Remove-Item -Path $marker `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};
		$localXMLFolder = @( Join-Path -Path $SourceTemplatesPath -ChildPath ( Split-Path -Path $localDestinationFile -Leaf ) );
		$localXMLFolder | .\tools\Build-OODocument.ps1 -DestinationPath $DestinationTemplatesPath -Force `
			-TempPath $PreprocessedTemplatesPath `
			-Version $version `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		Update-FileLastWriteTime -Path $marker `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};

	task $BuildAndOpenTaskName `
		-Inputs $prerequisites `
		-Outputs @( $target, $marker ) `
	{
		$localDestinationFile = $Outputs[0];
		$marker = $Outputs[1];
		if ( Test-Path -Path $marker ) {
			Remove-Item -Path $marker `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		};
		$localXMLFolder = @( Join-Path -Path $SourceTemplatesPath -ChildPath ( Split-Path -Path $localDestinationFile -Leaf ) );
		$localXMLFolder | .\tools\Build-OODocument.ps1 -DestinationPath $DestinationTemplatesPath -Force `
			-TempPath $PreprocessedTemplatesPath `
			-Version $version `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
		Update-FileLastWriteTime -Path $marker `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

		$Shell = New-Object -Com 'Shell.Application';
		$localDestinationFile | Get-Item | ForEach-Object {
			$verb = 'open';
			if ( $PSCmdlet.ShouldProcess( $_.FullName, $verb ) ) {
				$Shell.ShellExecute( $_.FullName, $null, $_.Directory.FullName, $verb, $OOWindowState );
			};
		};
	};
};

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build)
task Build $BuildTasks;

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build) и открывает их
task BuildAndOpen $BuildAndOpenTasks;

task . Build;
