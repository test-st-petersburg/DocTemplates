#Requires -Version 5.0
#Requires -Modules InvokeBuild

param(
	# путь к папке с .ott файлами
	[System.String]
	$DestinationPath = ( property DestinationPath ( ( Resolve-Path -Path '.\template' ).Path ) ),

	# имя .ott шаблона
	[System.String]
	$Filter = ( property Filter '*' ),

	# путь к .ott файлу
	[System.String[]]
	$DestinationFile = ( property DestinationFile `
		@( Get-ChildItem -Path $DestinationPath -Filter "$Filter.ott" | Select-Object -ExpandProperty FullName )
	),

	# путь к папке с xml папками .ott файлов
	[System.String]
	$SourcePath = ( property SourcePath ( ( Resolve-Path -Path '.\src\template' ).Path ) ),

	# путь к папке с xml файлами одного .ott файла
	[System.String[]]
	$SourceFolder = #( property SourceFolder `
	@( Get-ChildItem -Path $SourcePath -Directory -Filter "$Filter.ott" | Select-Object -ExpandProperty FullName )
	#)
	,

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


[System.String[]] $NewDestinationFile = ( $SourceFolder | ForEach-Object {
		Join-Path -Path $DestinationPath -ChildPath ( Split-Path -Path $_ -Leaf );
	} );

[System.String] $MarkerFileName = '.dirstate';

# Synopsis: Удаляет каталоги с XML файлами
task Clean {
	$SourceFolder | Where-Object { $_ } | Where-Object { Test-Path -Path $_ } | Remove-Item -Recurse -Force;
};

# Synopsis: Преобразовывает Open Office файлы в папки с XML файлами
task Unpack Clean, {
	$DestinationFile | .\tools\ConvertTo-PlainXML.ps1 -DestinationPath $SourcePath `
		-Indented `
		-WarningAction Continue `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
};

# Synopsis: Оптимизирует XML файлы Open Office
task OptimizeXML {
	$SourceFolder | .\tools\Optimize-PlainXML.ps1 `
		-WarningAction Continue `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
};

task UnpackAndOptimize Unpack, OptimizeXML;

$OOFilesUnpackTasks = @();
foreach ( $OOFile in $DestinationFile ) {
	$documentName = $( Split-Path -Path ( $OOFile ) -Leaf );
	$OOUnpackTaskName = "UnpackAndOptimize-$documentName";
	$OOFilesUnpackTasks += $OOUnpackTaskName;
	$targetFolder = Join-Path -Path $SourcePath -ChildPath $documentName;
	$target = Join-Path -Path $targetFolder -ChildPath 'META-INF/manifest.xml';
	$marker = Join-Path -Path $targetFolder -ChildPath $MarkerFileName;

	task $OOUnpackTaskName `
		-Inputs @( $OOFile ) `
		-Outputs @( $marker ) `
 {
		$localOOFile = $Inputs[0];
		$documentName = $( Split-Path -Path ( $localOOFile ) -Leaf );
		$localOOFile | .\tools\ConvertTo-PlainXML.ps1 -DestinationPath $SourcePath `
			-Indented `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );

		$localOOXMLFolder = Join-Path -Path $SourcePath -ChildPath $documentName;
		$localOOXMLFolder | .\tools\Optimize-PlainXML.ps1 `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};
};

# Synopsis: Распаковывает только изменённые файлы
task UnpackAndOptimizeModified $OOFilesUnpackTasks;

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build)
$BuildTasks = @();
$BuildAndOpenTasks = @();
foreach ( $documentXMLFolder in $SourceFolder ) {
	$documentName = $( Split-Path -Path ( $DocumentXMLFolder ) -Leaf );
	$BuildTaskName = "Build-$documentName";
	$BuildTasks += $BuildTaskName;
	$BuildAndOpenTaskName = "BuildAndOpen-$documentName";
	$BuildAndOpenTasks += $BuildAndOpenTaskName;
	$prerequisites = @( Get-ChildItem -Path $documentXMLFolder -File -Recurse );
	$target = Join-Path -Path $DestinationPath -ChildPath $documentName;
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
		$localXMLFolder = @( Join-Path -Path $SourcePath -ChildPath ( Split-Path -Path $localDestinationFile -Leaf ) );
		$localXMLFolder | .\tools\ConvertFrom-PlainXML.ps1 -DestinationPath $DestinationPath -Force `
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
		$localXMLFolder = @( Join-Path -Path $SourcePath -ChildPath ( Split-Path -Path $localDestinationFile -Leaf ) );
		$localXMLFolder | .\tools\ConvertFrom-PlainXML.ps1 -DestinationPath $DestinationPath -Force `
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
