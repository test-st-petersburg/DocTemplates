<#
.Synopsis
	Создаёт Open Office файлы из папки с xml файлами (build),
	либо разбираем файлы в папки XML файлов
#>
#Requires -Version 5.0
#Requires -Modules InvokeBuild

[CmdletBinding()]
param(
	# путь к папке с .ott файлами
	[Parameter( Mandatory = $false, Position = 0, ValueFromPipeline = $true )]
	[System.String]
	$DestinationPath = ( ( Get-Item -Path '.\template' ) | Resolve-Path ),

	# путь к .ott файлу
	[Parameter( Mandatory = $false )]
	[System.String[]]
	$DestinationFile = @( ( Get-ChildItem -Path $DestinationPath -File -Filter '*.ott' ) | Resolve-Path ),

	# путь к папке с xml папками .ott файлов
	[Parameter( Mandatory = $false, Position = 1 )]
	[System.String]
	$Path = ( ( Get-Item -Path '.\src\template' ) | Resolve-Path ),

	# путь к папке с xml файлами одного .ott файла
	[Parameter( Mandatory = $false )]
	[System.String[]]
	$XMLFolder = @( ( Get-ChildItem -Path $Path -Directory -Filter '*.ott' ) | Resolve-Path )
)

# Synopsis: Удаляет каталоги с XML файлами
task Clean {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	$XMLFolder | Where-Object { $_ } | Where-Object { Test-Path -Path $_ } | Remove-Item -Recurse -Force;
};

# Synopsis: Преобразовывает Open Office файлы в папки с XML файлами
task Unpack Clean, {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	$DestinationFile | .\tools\ConvertTo-PlainXML.ps1 -DestinationPath $Path `
		-Indented `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
};

# Synopsis: Оптимизирует XML файлы Open Office
task OptimizeXML {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	$XMLFolder | .\tools\Optimize-PlainXML.ps1 `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
		-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
};

task UnpackAndOptimize Unpack, OptimizeXML;

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build)

$OOFilesBuildTasks = @();

foreach ( $documentXMLFolder in $XMLFolder ) {
	$documentName = $( Split-Path -Path ( $DocumentXMLFolder ) -Leaf );
	$OOFilesBuildTask = "Build $documentName";
	$OOFilesBuildTasks += $OOFilesBuildTask;
	$prerequisites = @( Get-ChildItem -Path $documentXMLFolder -File -Recurse );
	$target = @( Join-Path -Path $DestinationPath -ChildPath $documentName );

	# dynamically added incremental task
	task $OOFilesBuildTask `
		-Inputs $prerequisites `
		-Outputs $target `
	{
		$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
		$localDestinationFile = $Outputs[0];
		$localXMLFolder = @( Join-Path -Path $Path -ChildPath ( Split-Path -Path $localDestinationFile -Leaf ) );
		$localXMLFolder | .\tools\ConvertFrom-PlainXML.ps1 -DestinationPath $DestinationPath -Force `
			-Verbose:( $PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent -eq $true ) `
			-Debug:( $PSCmdlet.MyInvocation.BoundParameters.Debug.IsPresent -eq $true );
	};
};

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build)
task Build $OOFilesBuildTasks;

task . Build;
