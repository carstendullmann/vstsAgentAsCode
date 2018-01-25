$Version = "0.1.0.0"
$OutputFolderPath = "$PSScriptRoot\Output\cVstsAgent\$Version"
if (Test-Path -Path $OutputFolderPath)
{
    Remove-Item -Path $OutputFolderPath -Recurse -Force    
}

New-Item -Path $OutputFolderPath -ItemType Directory | Out-Null
Copy-Item -Path $PSScriptRoot\cVstsAgent\cVstsAgent.psd1 -Destination $OutputFolderPath -Force
Copy-Item -Path $PSScriptRoot\cVstsAgent\DSCResources -Destination $OutputFolderPath -Recurse -Force

Get-ChildItem -Path $OutputFolderPath -Include "*.tests.ps1", "*.tests.settings.psd1" -Recurse | Remove-Item