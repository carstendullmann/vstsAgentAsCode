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
        [string]$PoolName,
        [PSCredential] $ServiceCredentials = $null
    )

    $existingConfig = Get-ExistingConfig -AgentFolder $AgentFolder -Token $Token
    if ($existingConfig.Agent) 
    {
        $existingPoolName = if ($existingConfig.PoolFromServer) { $existingConfig.PoolFromServer.Name } else { "[PoolId:$($existingConfig.Agent.poolId)]" }
        return @{
            Ensure      = "Present"
            Name        = $existingConfig.Agent.agentName 
            AgentFolder = $AgentFolder
            ServerUrl   = $existingConfig.Agent.serverUrl
            Token       = "**********************"
            PoolName    = $existingPoolName
            ServiceCredentials = "**********************"
        }
    }
    
    return @{
        Ensure      = "Absent"
        Name        = ""
        AgentFolder = ""
        ServerUrl   = ""
        Token       = ""
        PoolName    = ""
        ServiceCredentials = ""
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
        [string]$PoolName,
        [PSCredential] $ServiceCredentials = $null
    )

    $existingConfig = Get-ExistingConfig -AgentFolder $AgentFolder -Token $Token

    if ($Ensure -eq "Present" -and $existingConfig.Agent) 
    {
        Write-Verbose "Agent is present as requested. Reconfiguring it now."
        Remove-Agent -ServerUrl $ServerUrl -Token $Token -AgentFolder $AgentFolder
        Set-Agent -ServerUrl $ServerUrl -Token $Token -AgentFolder $AgentFolder -PoolName $PoolName -AgentName $Name -ServiceCredentials $ServiceCredentials
        return
    }

    if ($Ensure -eq "Present" -and -not $existingConfig.Agent) 
    {
        Write-Verbose "Agent was requested to be present, but is not. Configuring it now."
        Set-Agent -ServerUrl $ServerUrl -Token $Token -AgentFolder $AgentFolder -PoolName $PoolName -AgentName $Name -ServiceCredentials $ServiceCredentials
        return
    }

    if ($Ensure -eq "Absent" -and $existingConfig.Agent) 
    {
        Write-Verbose "Agent was requested to be absent, but is present. Removing it now."
        Remove-Agent -ServerUrl $ServerUrl -Token $Token -AgentFolder $AgentFolder
        return
    }

    if ($Ensure -eq "Absent" -and -not $existingConfig.Agent) 
    {
        Write-Verbose "Agent is absent as requested. Doing nothing."
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
        [string]$PoolName,
        [PSCredential] $ServiceCredentials = $null
    )

    $existingConfig = Get-ExistingConfig -AgentFolder $AgentFolder -Token $Token 
    $existingPoolName = if ($existingConfig.PoolFromServer) { $existingConfig.PoolFromServer.Name } else { "" }
    
    if ($Ensure -eq "Absent" -and $existingConfig.Agent) 
    {
        Write-Verbose "Agent was requested to be absent but is present."
        return $false
    }

    if ($Ensure -eq "Absent" -and -not $existingConfig.Agent) 
    {
        Write-Verbose "Agent is absent as requested."
        return $true
    }

    if ($Ensure -eq "Present" -and -not $existingConfig.Agent) 
    {
        Write-Verbose "Agent was requested to be present but is absent."
        return $false
    }

    if ($Ensure -eq "Present" -and $existingConfig.Agent) 
    {
        Write-Verbose "Agent is present as requested."
        if ($Name -ne $existingConfig.Agent.agentName)
        {
            Write-Verbose "Agent name does not match."
            return $false
        }
        
        if ($PoolName -ne $existingPoolName)
        {
            Write-Verbose "PoolName does not match."
            return $false
        }
        
        if ($ServerUrl -ne $existingConfig.Agent.serverUrl)
        {
            Write-Verbose "ServerUrl does not match."
            return $false
        }

        if ($existingConfig.AgentFromServer)
        {
            if ($existingConfig.AgentFromServer.name -ne $Name)
            {
                Write-Verbose "AgentName on server ($($existingConfig.AgentFromServer.name)) does not match requested name $Name."
                throw "Changing AgentName is currently not supported."
                return $false
            }

            if ($existingConfig.AgentFromServer.SystemCapabilities)
            {
                if ($existingConfig.AgentFromServer.SystemCapabilities."Agent.HomeDirectory")
                {
                    $AgentFolderOnServer = $existingConfig.AgentFromServer.SystemCapabilities."Agent.HomeDirectory"
                    if ($AgentFolderOnServer -ne $AgentFolder)
                    {
                        Write-Verbose "AgentFolder on server ($AgentFolderOnServer) does not match requested folder $AgentFolder."
                        throw "Changing AgentFolder is currently not supported."
                        return $false
                    }
                }
            }
        }
        
        return $true
    }

    throw "Ensure = '$Ensure'. Sure?"
}