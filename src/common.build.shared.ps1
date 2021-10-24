# Copyright © 2020 Sergei S. Betke

#Requires -Version 5.0

Set-StrictMode -Version Latest;

[System.String] $MarkerFileName = '.dirstate';

if ( -not ( Test-Path variable:RepoRootPath ) -or ( [System.String]::IsNullOrEmpty( $RepoRootPath ) ) )
{
	[System.String] $RepoRootPath =	( Resolve-Path -Path $PSScriptRoot/.. ).Path;
};


[System.String] $SourcePath = ( Join-Path -Path $RepoRootPath -ChildPath 'src' -Resolve );
[System.String] $SourceURIsPath = ( Join-Path -Path $SourcePath -ChildPath 'QRCodes/URIs' -Resolve );
[System.String] $SourceXCardPath = ( Join-Path -Path $SourcePath -ChildPath 'QRCodes/xCards' -Resolve );
[System.String] $SourceLibrariesPath = ( Join-Path -Path $SourcePath -ChildPath 'basic' -Resolve );
[System.String] $SourceTemplatesPath = ( Join-Path -Path $SourcePath -ChildPath 'template' -Resolve );
[System.String] $SourceDocumentsPath = ( Join-Path -Path $SourcePath -ChildPath 'doc' -Resolve );

[System.String] $TempPath = ( Join-Path -Path $RepoRootPath -ChildPath 'tmp' );
[System.String] $DestinationVCardPath = ( Join-Path -Path $TempPath -ChildPath 'vCards' );
[System.String] $DestinationQRCodesPath = ( Join-Path -Path $TempPath -ChildPath 'QRCodes' );
[System.String] $DestinationQRCodesURIPath = ( Join-Path -Path $DestinationQRCodesPath -ChildPath 'URIs' );
[System.String] $DestinationQRCodesVCardPath = ( Join-Path -Path $DestinationQRCodesPath -ChildPath 'vCards' );
[System.String] $DestinationLibContainersPath = ( Join-Path -Path $TempPath -ChildPath 'basic' );
[System.String] $PreprocessedTemplatesPath = ( Join-Path -Path $TempPath -ChildPath 'template' );
[System.String] $PreprocessedDocumentsPath = ( Join-Path -Path $TempPath -ChildPath 'doc' );

[System.String] $DestinationPath = ( Join-Path -Path $RepoRootPath -ChildPath 'output' );
[System.String] $DestinationLibrariesPath = ( Join-Path -Path $DestinationPath -ChildPath 'basic' );
[System.String] $DestinationTemplatesPath = ( Join-Path -Path $DestinationPath -ChildPath 'template' );
[System.String] $DestinationDocumentsPath = ( Join-Path -Path $DestinationPath -ChildPath 'doc' );

[System.String] $TemplatesFilter = '*.ott';
[System.String] $DocumentsFilter = '*.odt';


[System.String] $ToolsPath = ( Join-Path -Path $RepoRootPath -ChildPath 'tools' -Resolve );

[System.String] $NuGetToolsPath = ( Join-Path -Path $ToolsPath -ChildPath '.nuget' );
[System.String] $NuGetPath = ( Join-Path -Path $NuGetToolsPath -ChildPath 'nuget.exe' );

[System.String] $BuildToolsPath = ( Join-Path -Path $ToolsPath -ChildPath 'build' -Resolve );
[System.String] $UpdateFileLastWriteTimePath = ( Join-Path -Path $BuildToolsPath -ChildPath 'Update-FileLastWriteTime.ps1' -Resolve );

[System.String] $DocsToolsPath = ( Join-Path -Path $ToolsPath -ChildPath 'docs' -Resolve );
[System.String] $BuildOOMacroLibPath = ( Join-Path -Path $DocsToolsPath -ChildPath 'Build-OOMacroLib.ps1' -Resolve );
[System.String] $BuildOOMacroLibContainerPath = ( Join-Path -Path $DocsToolsPath -ChildPath 'Build-OOMacroLibContainer.ps1' -Resolve );
[System.String] $BuildOODocumentPath = ( Join-Path -Path $DocsToolsPath -ChildPath 'Build-OODocument.ps1' -Resolve );
[System.String] $ConvertToPlainXMLPath = ( Join-Path -Path $DocsToolsPath -ChildPath 'ConvertTo-PlainXML.ps1' -Resolve );
[System.String] $OptimizePlainXMLPath = ( Join-Path -Path $DocsToolsPath -ChildPath 'Optimize-PlainXML.ps1' -Resolve );
[System.String] $QRCodeToolsPath = ( Join-Path -Path $ToolsPath -ChildPath 'QRCode' -Resolve );
[System.String] $OutQRCodePath = ( Join-Path -Path $QRCodeToolsPath -ChildPath 'Out-QRCode.ps1' -Resolve );

[System.String] $vCardToolsPath = ( Join-Path -Path $ToolsPath -ChildPath 'xCard' -Resolve );
[System.String] $OutVCardPath = ( Join-Path -Path $vCardToolsPath -ChildPath 'Out-vCardFile.ps1' -Resolve );


# состояние окна приложения при открытии документа
# https://docs.microsoft.com/en-us/windows/win32/shell/shell-shellexecute
# 0  Open the application with a hidden window.
# 1  Open the application with a normal window. If the window is minimized or maximized, the system restores it to its original size and position.
# 2  Open the application with a minimized window.
# 3  Open the application with a maximized window.
# 4  Open the application with its window at its most recent size and position. The active window remains active.
# 5  Open the application with its window at its current size and position.
# 7  Open the application with a minimized window. The active window remains active.
# 10 Open the application with its window in the default state specified by the application.
[System.Int16] $WindowState = 10;


Function Get-BuildScript
{
	[CmdletBinding( DefaultParameterSetName = 'Path' )]
	[OutputType( [System.String[]] )]
	Param(
		# путь к каталогу, в дочерних каталогах которого будет выполнен поиск скриптов сборки
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $True, ParameterSetName = 'Path', ValueFromPipelineByPropertyName = $true )]
		[ValidateNotNullOrEmpty()]
		[SupportsWildcards()]
		[System.String[]]
		$Path,

		# путь к каталогу, в дочерних каталогах которого будет выполнен поиск скриптов сборки (без символов подстановки)
		[Parameter( Mandatory = $True, Position = 0, ParameterSetName = 'LiteralPath', ValueFromPipelineByPropertyName = $true )]
		[Alias('PSPath')]
		[ValidateNotNullOrEmpty()]
		[System.String[]]
		$LiteralPath,

		# фильтр для поиска сценариев сборки
		[Parameter( Mandatory = $False )]
		[System.String]
		$Filter = '*.build.ps1'
	)

	switch ( $PSCmdlet.ParameterSetName )
	{
		'Path'
		{
			$parameters = $PSBoundParameters;
			$null = $parameters.Remove( 'Path' );
			$Path | Resolve-Path | ForEach-Object { & $PSCmdlet.MyInvocation.MyCommand -LiteralPath ( $_.Path ) @parameters };
		}
		'LiteralPath'
		{
			return @(
				$LiteralPath | Where-Object { Test-Path -Path $_ } |
				Get-ChildItem -Directory |
				Get-ChildItem -File -Filter $Filter |
				Select-Object -ExpandProperty FullName
			);
		}
	}
}

Function Get-BuildScriptTag
{
	[CmdletBinding()]
	[OutputType( [System.String] )]
	Param(
		# путь к сценарию сборки
		[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $True )]
		[Alias('PSPath')]
		[Alias('Path')]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$LiteralPath
	)

	Split-Path -Path ( Split-Path -Path $LiteralPath -Parent ) -Leaf;
}

Function New-BuildSubTask
{
	[CmdletBinding( DefaultParameterSetName = 'Path' )]
	[OutputType()]
	Param(
		# задача сборки, которая будет создана, и при выполнении которой будут выполнены те же задачи для указанных сценариев сборки
		[Parameter( Mandatory = $True, Position = 0, ValueFromPipeline = $True )]
		[System.String[]]
		$Tasks,

		# путь к каталогу, в дочерних каталогах которого будет выполнен поиск скриптов сборки
		[Parameter( Mandatory = $True, Position = 1, ParameterSetName = 'Path' )]
		[ValidateNotNullOrEmpty()]
		[SupportsWildcards()]
		[System.String[]]
		$Path,

		# путь к каталогу, в дочерних каталогах которого будет выполнен поиск скриптов сборки (без символов подстановки)
		[Parameter( Mandatory = $True, ParameterSetName = 'LiteralPath' )]
		[Alias('PSPath')]
		[ValidateNotNullOrEmpty()]
		[System.String[]]
		$LiteralPath,

		# фильтр для поиска сценариев сборки
		[Parameter( Mandatory = $False, ParameterSetName = 'Path' )]
		[Parameter( Mandatory = $False, ParameterSetName = 'LiteralPath' )]
		[System.String]
		$Filter = '*.build.ps1',

		# пути к сценариям сборки
		[Parameter( Mandatory = $True, ParameterSetName = 'BuildScripts' )]
		[ValidateNotNullOrEmpty()]
		[System.String[]]
		$BuildScripts
	)

	switch ( $PSCmdlet.ParameterSetName )
	{
		'BuildScripts'
		{
			foreach ( $Task in $Tasks )
			{
				task -Name $Task;

				foreach ( $BuildScript in $BuildScripts )
				{
					task -Name "$Task-$( Get-BuildScriptTag $BuildScript )" `
						-Before $Task `
						-Jobs ( [ScriptBlock]::Create( "Invoke-Build -Task '$Task' -File '$BuildScript' @PSBoundParameters;" ) );
				};
			};
		}
		default
		{
			$parameters = $PSBoundParameters;
			$null = $parameters.Remove( 'Tasks' );
			& $PSCmdlet.MyInvocation.MyCommand -Tasks $Tasks -BuildScripts ( Get-BuildScript @parameters );
		}
	}
}


[System.String] $Version = ( gitversion /output json /showvariable SemVer );

$JobOpenFile = {
	$filePath = $Outputs[0];
	$Shell = New-Object -Com 'Shell.Application';
	$filePath | Get-Item | ForEach-Object {
		$verb = 'open';
		if ( $PSCmdlet.ShouldProcess( $_.FullName, $verb ) )
		{
			$Shell.ShellExecute( $_.FullName, $null, $_.Directory.FullName, $verb, $WindowState );
		};
	};
};


task nuget `
	-Inputs @( $MyInvocation.MyCommand.Path ) `
	-Outputs $NuGetPath `
	-Jobs {
	if ( -not ( Test-Path -Path $NuGetToolsPath ) )
	{
		New-Item -Path $NuGetToolsPath -ItemType Directory `
			-Verbose:( $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
			-Debug:( $DebugPreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
		| Out-Null;
	};
	$NuGetURI = 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe';
	Invoke-WebRequest $NuGetURI -OutFile $NuGetPath `
		-Verbose:( $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue ) `
		-Debug:( $DebugPreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue );
};

