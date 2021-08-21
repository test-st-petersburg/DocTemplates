#Requires -Version 5.0
# Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.2.0' }

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
		Get-ChildItem -Filter $DocumentsFilter | Select-Object -ExpandProperty FullName
	),

	# путь к папке с инструментами для сборки
	[System.String]
	$ToolsPath = ( ( Resolve-Path -Path '.\tools' ).Path ),

	# путь к папке с инструментами для документов
	[System.String]
	$DocsToolsPath = ( Join-Path -Path $ToolsPath -ChildPath 'docs' ),

	[System.String]
	$ODFValidatorPath = ( Join-Path -Path $DocsToolsPath -ChildPath 'ODFValidator' ),

	# путь к ODF validator JAR файлу
	[System.String]
	$ODFValidatorJarPath = ( Join-Path -Path $ODFValidatorPath -ChildPath 'ODFValidator.jar' )
)

chcp 65001 > $null;

Describe 'Open Document' {
	Describe '<Name>' -ForEach @(
		$DestinationDocFile | Get-Item |
		ForEach-Object { @{ Name = $_.Name; FullName = $_.FullName } }
	) {
		It 'is valid (by ODFValidator)' {
			{
				# chcp 866 > $null;
				try
				{
					java -D"file.encoding=UTF-8" -jar $ODFValidatorJarPath -e -w $FullName
					if ( $LASTEXITCODE -ne 0 )
					{
						Write-Error -Message 'Validation failed!' -ErrorAction 'Stop';
					};
				}
				finally
				{
					# chcp 65001 > $null;
				}
			} | Should -Not -Throw
		}
	}
}
