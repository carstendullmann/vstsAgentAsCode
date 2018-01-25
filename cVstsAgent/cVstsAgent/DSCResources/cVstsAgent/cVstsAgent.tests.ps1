# TODO: Make these pester tests 

# This file requires a file cVstsAgent.tests.settings.psd1 in the same directory, containing settings like so:

# @{
#     PAT = "<myPAT>"
#     ServerUrl = "https://<myaccount>.visualstudio.com"
#     ...
# }

$testSettings
Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName "cVstsAgent.tests.settings.psd1" -BindingVariable testSettings

# Tests =============

# Dot sourcing our code under test
. $PSScriptRoot\cVstsAgent.Implementation.ps1

# Get one agent's config from server
Get-PoolFromServer -ServerUrl $testSettings.ServerUrl `
    -Token $testSettings.PAT `
    -poolId 1

# Get one agent's config from server
Get-AgentFromServer -ServerUrl $testSettings.ServerUrl `
    -Token $testSettings.PAT `
    -poolId 1 `
    -agentId 24

Remove-Agent -ServerUrl $testSettings.ServerUrl `
    -Token $testSettings.PAT `
    -AgentFolder $testSettings.AgentFolder

Set-Agent -ServerUrl $testSettings.ServerUrl `
    -Token $testSettings.PAT `
    -AgentFolder $testSettings.AgentFolder `
    -PoolName $testSettings.PoolName `
    -AgentName $testSettings.AgentName

Get-ExistingConfig -AgentFolder $testSettings.AgentFolder `
    -Token $testSettings.PAT

