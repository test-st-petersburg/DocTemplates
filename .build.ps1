#Requires -Version 5.0
#Requires -Modules InvokeBuild
#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.2.0' }

param()

Set-StrictMode -Version Latest;
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

$parameters = $PSBoundParameters;

. $PSScriptRoot/src/common.build.shared.ps1

[System.String[]] $DestinationTemplateFile = @(
	$DestinationTemplatesPath | Where-Object { Test-Path -Path $_ } |
	Get-ChildItem -Filter $TemplatesFilter | Select-Object -ExpandProperty FullName
);

[System.String[]] $SourceTemplatesFolder = @(
	$SourceTemplatesPath | Where-Object { Test-Path -Path $_ } |
	Get-ChildItem -Directory -Filter $TemplatesFilter | Select-Object -ExpandProperty FullName
);

[System.String[]] $SourceDocumentsFolder = @(
	$SourceDocumentsPath | Where-Object { Test-Path -Path $_ } |
	Get-ChildItem -Directory |
	Get-ChildItem -Directory -Filter $DocumentsFilter | Select-Object -ExpandProperty FullName
);

[System.String[]] $SourceLibrariesFolder = @(
	$SourceLibrariesPath | Where-Object { Test-Path -Path $_ } |
	Get-ChildItem -Directory | Select-Object -ExpandProperty FullName
);

#region задачи распаковки и оптимизации .ott файлов в XML

$OOFilesUnpackTasks = @();
$OORemoveSourcesTasks = @();
$OOOptimizeTasks = @();
$OOUnpackAndOptimizeTasks = @();
foreach ( $OOFile in $DestinationTemplateFile )
{
	$documentName = $( Split-Path -Path ( $OOFile ) -Leaf );
	$OORemoveSourcesTaskName = "RemoveSources-$documentName";
	$OORemoveSourcesTasks += $OORemoveSourcesTaskName;
	$targetFolder = Join-Path -Path $SourceTemplatesPath -ChildPath $documentName;

	task $OORemoveSourcesTaskName -Outputs @( $targetFolder ) {
		$Outputs | Where-Object { $_ } | Where-Object { Test-Path -Path $_ } | Remove-Item -Recurse -Force;
	};

	$OOUnpackTaskName = "Unpack-$documentName";
	$OOFilesUnpackTasks += $OOUnpackTaskName;
	$target = Join-Path -Path $targetFolder -ChildPath 'META-INF/manifest.xml';
	$marker = Join-Path -Path $targetFolder -ChildPath $MarkerFileName;

	task $OOUnpackTaskName -Inputs @( $OOFile ) -Outputs @( $marker ) -Job $OORemoveSourcesTaskName, {
		$localOOFile = $Inputs[0];
		$localOOFile | & $ConvertToPlainXMLPath -DestinationPath $SourceTemplatesPath `
			-Indented `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
	};

	$OOOptimizeTaskName = "Optimize-$documentName";
	$OOOptimizeTasks += $OOOptimizeTaskName;

	task $OOOptimizeTaskName -Inputs @( $OOFile ) -Outputs @( '--unexisting-file--' ) -Job {
		$localOOFile = $Inputs[0];
		$documentName = $( Split-Path -Path ( $localOOFile ) -Leaf );
		$localOOXMLFolder = Join-Path -Path $SourceTemplatesPath -ChildPath $documentName;
		$localOOXMLFolder | & $OptimizePlainXMLPath `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
		& $UpdateFileLastWriteTimePath -LiteralPath $marker `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
	};

	$OOUnpackAndOptimizeTaskName = "UnpackAndOptimize-$documentName";
	$OOUnpackAndOptimizeTasks += $OOUnpackAndOptimizeTaskName;

	task $OOUnpackAndOptimizeTaskName -Inputs @( $OOFile ) -Outputs @( $marker ) `
		-Job $OOUnpackTaskName, $OOOptimizeTaskName;
};

# Synopsis: Удаляет каталоги с XML файлами
task RemoveSources $OORemoveSourcesTasks;

# Synopsis: Преобразовывает Open Office файлы в папки с XML файлами
task Unpack $OOFilesUnpackTasks;

# Synopsis: Оптимизирует XML файлы Open Office
task OptimizeXML $OOOptimizeTasks;

task UnpackAndOptimize $OOUnpackAndOptimizeTasks;

# Synopsis: Распаковывает только изменённые файлы
task UnpackAndOptimizeModified $OOUnpackAndOptimizeTasks;

#endregion

# Synopsis: Удаляет каталоги с временными файлами, собранными файлами документов и их шаблонов
task Clean {
	Invoke-Build Clean -File .\src\basic\MacroLibs.build.ps1 @parameters;
	Invoke-Build Clean -File .\src\QRCodes\URIs\QRCodes.URI.build.ps1 @parameters;
	Invoke-Build Clean -File .\src\QRCodes\xCards\QRCodes.xCards.build.ps1 @parameters;
	Invoke-Build Clean -File .\src\template\OpenDocumentTemplates.build.ps1 @parameters;
	Remove-BuildItem $DestinationPath, $TempPath;
};

# Synopsis: Создаёт библиотеки макросов Open Office
task BuildLibs {
	Invoke-Build BuildLibs -File .\src\basic\MacroLibs.build.ps1 @parameters;
};

# Synopsis: Создаёт контейнеры библиотек макросов Open Office для последующей интеграции в шаблоны и документы
task BuildLibContainers {
	Invoke-Build BuildLibContainers -File .\src\basic\MacroLibs.build.ps1 @parameters;
};

# Synopsis: Создаёт файлы с изображениями QR кодов (с URL)
task BuildUriQRCodes {
	Invoke-Build BuildUriQRCodes -File .\src\QRCodes\URIs\QRCodes.URI.build.ps1 @parameters;
};

# Synopsis: Создаёт vCard из xCard
task BuildVCards {
	Invoke-Build BuildVCards -File .\src\QRCodes\xCards\QRCodes.xCards.build.ps1 @parameters;
};

# Synopsis: Создаёт файлы с изображениями QR кодов (с vCard)
task BuildVCardQRCodes {
	Invoke-Build BuildVCardQRCodes -File .\src\QRCodes\xCards\QRCodes.xCards.build.ps1 @parameters;
};

# Synopsis: Создаёт файлы с изображениями QR кодов
task BuildQRCodes BuildUriQRCodes, BuildVCardQRCodes;

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build)
task BuildTemplates {
	Invoke-Build BuildTemplates -File .\src\template\OpenDocumentTemplates.build.ps1 @parameters;
};

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build) и открывает их
task BuildAndOpenTemplates {
	Invoke-Build BuildAndOpenTemplates -File .\src\template\OpenDocumentTemplates.build.ps1 @parameters;
};

#region сборка документов

$BuildDocsTasks = @();
$BuildAndOpenDocsTasks = @();
foreach ( $documentXMLFolder in $SourceDocumentsFolder )
{
	Push-Location -LiteralPath $SourceDocumentsPath;
	try
	{
		[System.String] $documentRelativePath = ( Resolve-Path -LiteralPath $documentXMLFolder -Relative );
	}
	finally
	{
		Pop-Location;
	};
	[System.String] $documentTag = $documentRelativePath;

	$documentName = $( Split-Path -Path ( $DocumentXMLFolder ) -Leaf );
	$BuildTaskName = "Build-$documentTag";
	$BuildDocsTasks += $BuildTaskName;
	$prerequisites = @( Get-ChildItem -Path $documentXMLFolder -File -Recurse -Exclude $MarkerFileName );
	$target = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
		( Join-Path -Path $DestinationDocumentsPath -ChildPath $documentRelativePath ) );
	$marker = Join-Path -Path $documentXMLFolder -ChildPath $MarkerFileName;

	$JobBuildDocument = {
		$destFile = $Outputs[0];
		$marker = $Outputs[1];
		$sourcePath = ( $Inputs | Get-Item | Where-Object -FilterScript { $_.Name -eq 'manifest.xml' } )[0].Directory.FullName | Split-Path -Parent;
		Push-Location -LiteralPath $SourceDocumentsPath;
		try
		{
			[System.String] $documentRelativePath = ( Resolve-Path -LiteralPath $sourcePath -Relative );
		}
		finally
		{
			Pop-Location;
		};
		if ( Test-Path -Path $marker )
		{
			Remove-Item -Path $marker `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
		};
		$PreprocessedDocumentPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
			( Join-Path -Path $PreprocessedDocumentsPath -ChildPath $documentRelativePath ) );
		& $BuildOODocumentPath -LiteralPath $sourcePath -Destination $destFile -Force `
			-PreprocessedPath $PreprocessedDocumentPath `
			-LibrariesPath $DestinationLibrariesPath `
			-TemplatesPath $PreprocessedTemplatesPath `
			-Version $Version `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
		& $UpdateFileLastWriteTimePath -LiteralPath $marker `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
	};

	task $BuildTaskName `
		-Inputs $prerequisites `
		-Outputs @( $target, $marker ) `
		-Job BuildTemplates, $JobBuildDocument;

	$BuildAndOpenTaskName = "BuildAndOpen-$documentTag";
	$BuildAndOpenDocsTasks += $BuildAndOpenTaskName;

	task $BuildAndOpenTaskName `
		-Inputs $prerequisites `
		-Outputs @( $target, $marker ) `
		-Job BuildTemplates, $JobBuildDocument, $JobOpenFile;
};

# Synopsis: Создаёт Open Office файлы документов из папок с XML файлами (build)
task BuildDocs $BuildDocsTasks;

# Synopsis: Создаёт Open Office файлы документов из папок с XML файлами (build) и открывает их
task BuildAndOpenDocs $BuildAndOpenDocsTasks;

#endregion

task Build BuildTemplates, BuildDocs;

task BuildAndOpen BuildAndOpenTemplates, BuildAndOpenDocs;

# Synopsis: тестирование собранных шаблонов и файлов
task Test Build, {
	Invoke-Pester -Configuration ( Import-PowerShellDataFile -LiteralPath '.\tests\ODFValidator.pester-config.psd1' );
};

task . Test;
