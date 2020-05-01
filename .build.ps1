#Requires -Version 5.0
#Requires -Modules InvokeBuild

param(
	# путь к папке с .ott файлами
	[System.String]
	$DestinationPath = ( property DestinationPath ( ( Get-Item -Path '.\template' ).FullName ) ),

	# имя .ott шаблона
	[System.String]
	$Filter = ( property Filter '*' ),

	# путь к .ott файлу
	[System.String[]]
	$DestinationFile = ( property DestinationFile @( Get-ChildItem -Path $DestinationPath -File -Filter "$Filter.ott" ).FullName ),

	# путь к папке с xml папками .ott файлов
	[System.String]
	$SourcePath = ( property SourcePath ( ( Get-Item -Path '.\src\template' ) | Resolve-Path ) ),

	# путь к папке с xml файлами одного .ott файла
	[System.String[]]
	$SourceFolder = ( property SourceFolder @( Get-ChildItem -Path $SourcePath -Directory -Filter "$Filter.ott" ).FullName ),

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

[System.String[]] $NewDestinationFile = $SourceFolder | ForEach-Object {
	Join-Path -Path $DestinationPath -ChildPath ( Split-Path -Path $_ -Leaf );
};

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

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build)

$OOFilesBuildTasks = @();

foreach ( $documentXMLFolder in $SourceFolder ) {
	$documentName = $( Split-Path -Path ( $DocumentXMLFolder ) -Leaf );
	$OOFilesBuildTask = "Build-$documentName";
	$OOFilesBuildTasks += $OOFilesBuildTask;
	$prerequisites = @( Get-ChildItem -Path $documentXMLFolder -File -Recurse );
	$target = @( Join-Path -Path $DestinationPath -ChildPath $documentName );

	task $OOFilesBuildTask `
		-Inputs $prerequisites `
		-Outputs $target `
	{
		$localDestinationFile = $Outputs[0];
		$localXMLFolder = @( Join-Path -Path $SourcePath -ChildPath ( Split-Path -Path $localDestinationFile -Leaf ) );
		$localXMLFolder | .\tools\ConvertFrom-PlainXML.ps1 -DestinationPath $DestinationPath -Force `
			-WarningAction Continue `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};
};

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build)
task Build $OOFilesBuildTasks;

task BuildAndOpen Build, {
	$Shell = New-Object -Com 'Shell.Application';
	$NewDestinationFile | Get-Item | ForEach-Object {
		$verb = 'open';
		if ( $PSCmdlet.ShouldProcess( $_.FullName, $verb ) ) {
			$Shell.ShellExecute( $_.FullName, $null, $_.Directory.FullName, $verb, $OOWindowState );
		};
	};
};

task . Build;
