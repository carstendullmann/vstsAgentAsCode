# See https://docs.microsoft.com/en-us/powershell/dsc/authoringresourcemof
# https://docs.microsoft.com/en-us/powershell/dsc/resourceauthoringchecklist

# Dotsourcing our implementation (helper methods)
. $PSScriptRoot\cVstsAgent.Implementation.ps1

# DSC uses the Get-TargetResource function to fetch the status of the resource instance specified in the parameters for the target machine
function Get-TargetResource
{
    param
    (
        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AgentFolder,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ServerUrl,

        [string]$Token,
        [string]$PoolName
    )

    $existingConfig = Get-ExistingConfig -AgentFolder $AgentFolder -Token $Token
    if ($existingConfig.Agent) 
    {
        $serviceName = ""
        if ($existingConfig.Service) 
        {
            $serviceName = $existingConfig.Service
        }

        return @{
            Ensure      = "Present"
            Name        = $existingConfig.Agent.agentName 
            AgentFolder = $AgentFolder
            ServerUrl   = $existingConfig.Agent.serverUrl
            Token       = ""
            PoolName    = ""
        }
    }
    
    return @{
        Ensure      = "Absent"
        Name        = ""
        AgentFolder = ""
        ServerUrl   = ""
        Token       = ""
        PoolName    = ""
    }
}

# The Set-TargetResource function is used to create, delete or configure a website on the target machine. 
function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AgentFolder,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ServerUrl,

        [string]$Token,
        [string]$PoolName
    )

    $existingConfig = Get-ExistingConfig -AgentFolder $AgentFolder -Token $Token

    if ($Ensure -eq "Present" -and $existingConfig.Agent) 
    {
        $needsReconfigure = $false
        # Agent exists. Check whether all settings are correct, otherwise reconfigure.
        if ($existingConfig.Agent.agentName -ne $Name) 
        {
            throw "Trying to change the name from $($existingConfig.Agent.agentName) to $Name for agent in folder $AgentFolder. Changing names or agent folders is currently not supported."
        }

        if ($existingConfig.Agent.serverUrl -ne $ServerUrl) 
        {
            # This is effectively moving the agent to another server
            $needsReconfigure = $true
        }

        # Currently the only thing we can reconfigure is the ServerUrl
        
        return
    }

    if ($Ensure -eq "Present" -and -not $existingConfig.Agent) 
    {
        # Agent not there yet. Configure it.
        
        return
    }

    if ($Ensure -eq "Absent" -and $existingConfig.Agent) 
    {
        # Agent exists. Unconfigure it and delete the agent folder.
        return
    }

    if ($Ensure -eq "Absent" -and -not $existingConfig.Agent) 
    {
        # Agent exists. Unconfigure it and delete the agent folder.
        return
    }

    throw "Ensure = '$Ensure'. Sure?"
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AgentFolder,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ServerUrl,

        [string]$Token,
        [string]$PoolName
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    #Include logic to 
    $result = [System.Boolean]
    #Add logic to test whether the website is present and its status mathes the supplied parameter values. If it does, return true. If it does not, return false.
    $result
}