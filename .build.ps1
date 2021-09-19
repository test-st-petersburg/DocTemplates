#Requires -Version 5.0
#Requires -Modules InvokeBuild
#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.2.0' }

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

	# путь к папке с .odt файлами
	[System.String]
	$DestinationDocumentsPath = ( property DestinationDocumentsPath (
			Join-Path -Path $DestinationPath -ChildPath 'doc'
		) ),

	# имя .odt шаблона
	[System.String]
	$DocumentsFilter = ( property DocumentsFilter '*.odt' ),

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

	# путь к папке временного хранения препроцессированных XML файлов перед сборкой документов и шаблонов
	[System.String]
	$PreprocessedDocumentsPath = ( property PreprocessedDocumentsPath (
			Join-Path -Path $TempPath -ChildPath 'doc'
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
			Get-ChildItem -Directory -Filter $TemplatesFilter | Select-Object -ExpandProperty FullName
		) ),

	# путь к папке с xml папками .odt файлов
	[System.String]
	$SourceDocumentsPath = ( property SourceDocumentsPath (
			Join-Path -Path $SourcePath -ChildPath 'doc'
		) ),

	# пути к папкам с xml файлами .odt файлов
	[System.String[]]
	$SourceDocumentsFolder = ( property SourceDocumentsFolder @(
			$SourceDocumentsPath | Where-Object { Test-Path -Path $_ } |
			Get-ChildItem -Directory -Filter $DocumentsFilter | Select-Object -ExpandProperty FullName
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

	# путь к папке с .url файлами для генерации QR кодов
	[System.String]
	$SourceURIsPath = ( property SourceURIsPath (
			Join-Path -Path $SourcePath -ChildPath 'QRCodes\URIs'
		) ),

	# пути к .url файлам для генерации QR кодов
	[System.String[]]
	$SourceURIsFiles = ( property SourceURIsFiles @(
			$SourceURIsPath | Where-Object { Test-Path -Path $_ } |
			Get-ChildItem -File -Filter '*.url' | Select-Object -ExpandProperty FullName
		) ),

	# путь к временной папке со сгенерированными изображениями QR кодов
	[System.String]
	$DestinationQRCodesPath = ( property DestinationQRCodesPath (
			Join-Path -Path $TempPath -ChildPath 'QRCodes'
		) ),

	# путь к папке с xCard .xml файлами для генерации QR кодов
	[System.String]
	$SourceXCardPath = ( property SourceXCardPath (
			Join-Path -Path $SourcePath -ChildPath 'QRCodes\xCards'
		) ),

	# пути к .url файлам для генерации QR кодов
	[System.String[]]
	$SourceXCardsFiles = ( property SourceXCardsFiles @(
			$SourceXCardPath | Where-Object { Test-Path -Path $_ } |
			Get-ChildItem -File -Filter '*.xml' | Select-Object -ExpandProperty FullName
		) ),

	# путь к временной папке со сгенерированными vCard
	[System.String]
	$DestinationVCardPath = ( property DestinationVCardPath (
			Join-Path -Path $TempPath -ChildPath 'vCards'
		) ),

	# путь к папке с инструментами для сборки
	[System.String]
	$ToolsPath = ( property ToolsPath ( ( Resolve-Path -Path '.\tools' ).Path ) ),

	# путь к папке со вспомогательными инструментами
	[System.String]
	$BuildToolsPath = ( property BuildToolsPath (
			Join-Path -Path $ToolsPath -ChildPath 'build'
		) ),

	# путь к инструменту аналогу touch
	[System.String]
	$UpdateFileLastWriteTimePath = ( property UpdateFileLastWriteTimePath (
			Join-Path -Path $BuildToolsPath -ChildPath 'Update-FileLastWriteTime.ps1'
		) ),

	# путь к папке с инструментами для документов
	[System.String]
	$DocsToolsPath = ( property DocsToolsPath (
			Join-Path -Path $ToolsPath -ChildPath 'docs'
		) ),

	# путь к инструменту распаковки документов в XML
	[System.String]
	$ConvertToPlainXMLPath = ( property ConvertToPlainXMLPath (
			Join-Path -Path $DocsToolsPath -ChildPath 'ConvertTo-PlainXML.ps1'
		) ),

	# путь к инструменту оптимизации XML файлов документов
	[System.String]
	$OptimizePlainXMLPath = ( property OptimizePlainXMLPath (
			Join-Path -Path $DocsToolsPath -ChildPath 'Optimize-PlainXML.ps1'
		) ),

	# путь к инструменту оптимизации XML файлов документов
	[System.String]
	$BuildOODocumentPath = ( property BuildOODocumentPath (
			Join-Path -Path $DocsToolsPath -ChildPath 'Build-OODocument.ps1'
		) ),

	# путь к инструменту сборки библиотек макрокоманд
	[System.String]
	$BuildOOMacroLibPath = ( property BuildOOMacroLibPath (
			Join-Path -Path $DocsToolsPath -ChildPath 'Build-OOMacroLib.ps1'
		) ),

	# путь к инструменту сборки контейнеров библиотек макрокоманд
	[System.String]
	$BuildOOMacroLibContainerPath = ( property BuildOOMacroLibContainerPath (
			Join-Path -Path $DocsToolsPath -ChildPath 'Build-OOMacroLibContainer.ps1'
		) ),

	# путь к папке с инструментами для документов
	[System.String]
	$QRCodeToolsPath = ( property QRCodeToolsPath (
			Join-Path -Path $ToolsPath -ChildPath 'QRCode'
		) ),

	# путь к инструменту подготовки QR кодов
	[System.String]
	$OutQRCodePath = ( property OutQRCodePath (
			Join-Path -Path $QRCodeToolsPath -ChildPath 'Out-QRCode.ps1'
		) ),

	# путь к папке с инструментами для документов
	[System.String]
	$vCardToolsPath = ( property vCardToolsPath (
			Join-Path -Path $ToolsPath -ChildPath 'xCard'
		) ),

	# путь к инструменту подготовки QR кодов
	[System.String]
	$OutVCardPath = ( property OutVCardPath (
			Join-Path -Path $vCardToolsPath -ChildPath 'Out-vCardFile.ps1'
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
	$Version = ( property Version ( gitversion /output json /showvariable SemVer ) )
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;

$BuildParameters = $PSBoundParameters;

[System.String] $RepoRootPath = ( Get-Location ).Path;
[System.String] $MarkerFileName = '.dirstate';

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

#region задачи сборки шаблонов, документов, библиотек макросов

# Synopsis: Удаляет каталоги с временными файлами, собранными файлами документов и их шаблонов
task Clean {
	Invoke-Build Clean -File .\src\basic\MacroLibs.build.ps1 `
		-RepoRootPath $RepoRootPath `
		-DestinationLibrariesPath $DestinationLibrariesPath `
		-DestinationLibContainersPath $DestinationLibContainersPath `
		-SourceLibrariesPath $SourceLibrariesPath `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
	Remove-BuildItem $DestinationPath, $TempPath;
};

#region сборка библиотек макросов

# Synopsis: Создаёт библиотеки макросов Open Office
task BuildLibs {
	Invoke-Build BuildLibs -File .\src\basic\MacroLibs.build.ps1 `
		-RepoRootPath $RepoRootPath `
		-DestinationLibrariesPath $DestinationLibrariesPath `
		-DestinationLibContainersPath $DestinationLibContainersPath `
		-SourceLibrariesPath $SourceLibrariesPath `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
};

# Synopsis: Создаёт контейнеры библиотек макросов Open Office для последующей интеграции в шаблоны и документы
task BuildLibContainers {
	Invoke-Build BuildLibContainers -File .\src\basic\MacroLibs.build.ps1 `
		-RepoRootPath $RepoRootPath `
		-DestinationLibrariesPath $DestinationLibrariesPath `
		-DestinationLibContainersPath $DestinationLibContainersPath `
		-SourceLibrariesPath $SourceLibrariesPath `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
};

#endregion

#region генерация QR кодов

$BuildUriQRCodesTasks = @();
foreach ( $SourceURIFile in $SourceURIsFiles )
{
	$UriName = [System.IO.Path]::GetFileNameWithoutExtension( $SourceURIFile );
	$UriQRCodeName = "$UriName.png";
	$BuildTaskName = "BuildLib-$UriQRCodeName";
	$BuildUriQRCodesTasks += $BuildTaskName;
	$prerequisites = $SourceURIFile;
	$target = Join-Path -Path $DestinationQRCodesPath -ChildPath $UriQRCodeName;

	task $BuildTaskName `
		-Inputs $prerequisites `
		-Outputs $target `
	{
		$DestinationQRCodeFile = $Outputs;
		$SourceUriFile = $Inputs[0];

		Write-Verbose "Generate QR code file `"$DestinationQRCodeFile`" from `"$SourceUriFile`"";
		$SourceURL = Get-Content -LiteralPath $SourceUriFile `
		| Select-String -Pattern '(?<=^URL=\s*).*?(\s*)$'  -AllMatches `
		| Foreach-Object { $_.Matches } | Foreach-Object { $_.Groups[0].Value };
		Write-Verbose "Source URL `"$SourceURL`"";

		if ( -not ( Test-Path -Path $DestinationQRCodesPath ) )
		{
			New-Item -Path $DestinationQRCodesPath -ItemType Directory `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true ) `
			| Out-Null;
		};

		$SourceURL | & $OutQRCodePath -FilePath $DestinationQRCodeFile `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
	};

};

# TODO: временно. Найти другое решение для размещения QR кодов в документах
task 'Build-org-site-in-ott.png' `
	-Inputs @( ( Join-Path -Path $SourceURIsPath -ChildPath 'org-site.url' ) ) `
	-Outputs @( ( Join-Path -Path $SourceTemplatesPath -ChildPath 'ОРД ФБУ Тест-С.-Петербург v2.ott\Pictures\1000000000000025000000257FD278A9E707D95C.png' ) ) `
	-Job $JobBuildUriQRCode;

# Synopsis: Создаёт файлы с изображениями QR кодов (с URL)
# task BuildUriQRCodes @( $BuildUriQRCodesTasks, 'Build-org-site-in-ott.png' );
task BuildUriQRCodes $BuildUriQRCodesTasks;

$BuildVCardQRCodesTasks = @();
foreach ( $SourceXCardFile in $SourceXCardsFiles )
{
	$cardName = [System.IO.Path]::GetFileNameWithoutExtension( $SourceXCardFile );
	$QRCodeName = "$cardName.png";
	$BuildTaskName = "Build-$QRCodeName";
	$BuildVCardQRCodesTasks += $BuildTaskName;
	$prerequisites = $SourceXCardFile;
	$target = Join-Path -Path $DestinationQRCodesPath -ChildPath $QRCodeName;
	$vCardName = "$cardName.vcf";
	$BuildVCardTaskName = "Build-$vCardName";
	$vCardTarget = Join-Path -Path $DestinationVCardPath -ChildPath $vCardName;

	task $BuildVCardTaskName `
		-Inputs $prerequisites `
		-Outputs $vCardTarget `
	{
		$vCardFile = $Outputs;
		$SourceXCardFile = $Inputs[0];

		Write-Verbose "Generate vCard `"$vCardFile`" from xCard `"$SourceXCardFile`"";
		if ( -not ( Test-Path -Path $DestinationVCardPath ) )
		{
			New-Item -Path $DestinationVCardPath -ItemType Directory `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true ) `
			| Out-Null;
		};

		& $OutVCardPath -LiteralPath $SourceXCardFile -Destination $vCardFile `
			-Compatibility 'Android' -Minimize `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
	};

	task $BuildTaskName `
		-Inputs $vCardTarget `
		-Outputs $target `
		-Jobs $BuildVCardTaskName,
	{
		$DestinationQRCodeFile = $Outputs;
		$vCardFile = $Inputs[0];

		Write-Verbose "Generate QR code file `"$DestinationQRCodeFile`" from vCard `"$vCardFile`"";
		if ( -not ( Test-Path -Path $DestinationQRCodesPath ) )
		{
			New-Item -Path $DestinationQRCodesPath -ItemType Directory `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true ) `
			| Out-Null;
		};

		Get-Content -LiteralPath $vCardFile -Raw `
		| & $OutQRCodePath -FilePath $DestinationQRCodeFile `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
	};
};

# Synopsis: Создаёт файлы с изображениями QR кодов (с vCard)
task BuildVCardQRCodes $BuildVCardQRCodesTasks;

# Synopsis: Создаёт файлы с изображениями QR кодов
task BuildQRCodes BuildUriQRCodes, BuildVCardQRCodes;

#endregion

#region сборка шаблонов

$JobOpenFile = {
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

	$JobBuildTemplate = {
		$localDestinationFile = $Outputs[0];
		$marker = $Outputs[1];
		if ( Test-Path -Path $marker )
		{
			Remove-Item -Path $marker `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
		};
		$localXMLFolder = @( Join-Path -Path $SourceTemplatesPath -ChildPath ( Split-Path -Path $localDestinationFile -Leaf ) );
		$localXMLFolder | & $BuildOODocumentPath -DestinationPath $DestinationTemplatesPath -Force `
			-TempPath $PreprocessedTemplatesPath `
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
		-Job BuildLibs, BuildQRCodes, $JobBuildTemplate;

	task $BuildAndOpenTaskName `
		-Inputs $prerequisites `
		-Outputs @( $target, $marker ) `
		-Job BuildLibs, BuildQRCodes, $JobBuildTemplate, $JobOpenFile;
};

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build)
task BuildTemplates $BuildTemplatesTasks;

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build) и открывает их
task BuildAndOpenTemplates $BuildAndOpenTemplatesTasks;

#endregion

#region сборка документов

$BuildDocsTasks = @();
$BuildAndOpenDocsTasks = @();
foreach ( $documentXMLFolder in $SourceDocumentsFolder )
{
	$documentName = $( Split-Path -Path ( $DocumentXMLFolder ) -Leaf );
	$BuildTaskName = "Build-$documentName";
	$BuildDocsTasks += $BuildTaskName;
	$prerequisites = @( Get-ChildItem -Path $documentXMLFolder -File -Recurse -Exclude $MarkerFileName );
	$target = Join-Path -Path $DestinationDocumentsPath -ChildPath $documentName;
	$marker = Join-Path -Path $documentXMLFolder -ChildPath $MarkerFileName;

	$JobBuildDocument = {
		$localDestinationFile = $Outputs[0];
		$marker = $Outputs[1];
		if ( Test-Path -Path $marker )
		{
			Remove-Item -Path $marker `
				-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true ) `
				-Debug:( $PSCmdlet.MyInvocation.BoundParameters['Debug'] -eq $true );
		};
		$localXMLFolder = @( Join-Path -Path $SourceDocumentsPath -ChildPath ( Split-Path -Path $localDestinationFile -Leaf ) );
		$localXMLFolder | & $BuildOODocumentPath -DestinationPath $DestinationDocumentsPath -Force `
			-TempPath $PreprocessedDocumentsPath `
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

	$BuildAndOpenTaskName = "BuildAndOpen-$documentName";
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

#region тестирование собранных шаблонов и файлов

task Test Build, {
	Invoke-Pester -Configuration ( Import-PowerShellDataFile -LiteralPath '.\tests\ODFValidator.pester-config.psd1' );
};

#endregion

task . Test;

#endregion
