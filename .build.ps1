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
	$DestinationFile = ( ( Get-ChildItem -Path $DestinationPath -File -Filter '*.ott' ) | Resolve-Path ),

	# путь к папке с xml папками .ott файлов
	[Parameter( Mandatory = $false, Position = 1 )]
	[System.String]
	$Path = ( ( Get-Item -Path '.\src\template' ) | Resolve-Path ),

	# путь к папке с xml файлами одного .ott файла
	[Parameter( Mandatory = $false )]
	[System.String[]]
	$XMLFolder = ( ( Get-ChildItem -Path $Path -Directory -Filter '*.ott' ) | Resolve-Path )
)

# Synopsis: Удаляет каталоги с XML файлами
task Clean {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	$XMLFolder | Where-Object { $_ } | Where-Object { Test-Path -Path $_ } | Remove-Item -Recurse -Force;
};

# task Build - `
# 	-Outputs @() `
# 	-Inputs @() `
# {
# 	process {
# 	}
# }

# Synopsis: Преобразовывает Open Office файлы в папки с XML файлами
task Unpack Clean, {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	$DestinationFile | .\tools\ConvertTo-PlainXML.ps1 -DestinationPath $Path `
		-Indented `
		-Verbose;
};

# Synopsis: Создаёт Open Office файлы из папки с XML файлами (build)
task Build {
	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
	$XMLFolder | .\tools\ConvertFrom-PlainXML.ps1 -DestinationPath $DestinationPath -Force `
		-Verbose;
};

task . Build;
