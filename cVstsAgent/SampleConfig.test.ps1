$testSettings
Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName "SampleConfig.test.settings.psd1" -BindingVariable testSettings

& $PSScriptRoot\Build-Resource.ps1
& $PSScriptRoot\Install-Resource.ps1

. $PSScriptRoot\SampleConfig.ps1

SampleConfig -Token $testSettings.PAT -OutputPath $PSScriptRoot\SampleConfig

Start-DscConfiguration -Path $PSScriptRoot\SampleConfig -Wait -Verbose -Force