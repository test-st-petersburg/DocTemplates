﻿#Requires -Version 5.0
#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.3.0' }

param(
	# путь к папке с генерируемыми файлами
	[System.String]
	$DestinationPath = ( Join-Path -Path ( ( Get-Location ).Path ) -ChildPath 'output' ),

	# путь к папке с .odt файлами
	[System.String]
	$DestinationDocumentsPath = ( Join-Path -Path $DestinationPath -ChildPath 'doc' ),

	# имя .odt шаблона
	[System.String]
	$DocumentsFilter = '*.odt',

	# пути к .odt файлам
	[System.String[]]
	$DestinationDocFile = @(
		$DestinationDocumentsPath | Where-Object { Test-Path -Path $_ } |
		Get-ChildItem -Directory |
		Get-ChildItem -Filter $DocumentsFilter |
		Select-Object -ExpandProperty FullName
	),

	# путь к папке с инструментами для сборки
	[System.String]
	$ToolsPath = ( ( Resolve-Path -Path '.\tools' ).Path ),

	# путь к папке с инструментами для документов
	[System.String]
	$DocsToolsPath = ( Join-Path -Path $ToolsPath -ChildPath 'docs' )
)

BeforeAll {
	chcp 65001 > $null;
}

BeforeAll {
	& $PSScriptRoot/../Prepare-ODFValidator.ps1;
	[System.String] $ODFValidatorPath = ( Join-Path -Path $PSScriptRoot -ChildPath '../java/dependency' );
	[System.String] $ODFValidatorJarPath = ( Get-ChildItem -LiteralPath $ODFValidatorPath -Filter 'ODFValidator-*.jar' -File )[0].FullName;
}

Describe 'Open Documents' {

	Describe '<Name>' -ForEach @(
		$DestinationDocFile | Get-Item |
		ForEach-Object {
			Push-Location -LiteralPath $DestinationDocumentsPath;
			try
			{
				[System.String] $DocumentRelativePath = ( Resolve-Path -LiteralPath ( $_.FullName ) -Relative );
			}
			finally
			{
				Pop-Location;
			};
			@{
				Name = $DocumentRelativePath;
				FullName = $_.FullName;
			};
		}
	) {
		It 'is valid (by ODFValidator)' -Tag 'ODFValidator' {
			# chcp 866 > $null;
			try
			{
				java -D"file.encoding=UTF-8" -jar $ODFValidatorJarPath -e -w $FullName
			}
			finally
			{
				# chcp 65001 > $null;
			}
			$LASTEXITCODE | Should -Be 0;
		}
	}
}
