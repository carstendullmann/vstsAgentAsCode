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

        [PSCredential] $Token,
        [PSCredential] $ServiceCredentials = $null,
        [String] $PoolName = "default",
        [String] $LocalAgentSource = $null,
        [String] $WorkFolder = "_work"
    )

    $PlainToken = $Token.GetNetworkCredential().Password
    $existingConfig = Get-ExistingConfig -AgentFolder $AgentFolder -Token $PlainToken
    if ($existingConfig.Agent) 
    {
        $existingPoolName = if ($existingConfig.PoolFromServer) { $existingConfig.PoolFromServer.Name } else { "[PoolId:$($existingConfig.Agent.poolId)]" }
        return @{
            Ensure             = "Present"
            Name               = $existingConfig.Agent.agentName 
            AgentFolder        = $AgentFolder
            ServerUrl          = $existingConfig.Agent.serverUrl
            PoolName           = $existingPoolName
            LocalAgentSource   = ""
            WorkFolder         = ""
        }
    }
    
    return @{
        Ensure             = "Absent"
        Name               = ""
        AgentFolder        = ""
        ServerUrl          = ""
        PoolName           = ""
        LocalAgentSource   = ""
        WorkFolder         = ""
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

        [PSCredential] $Token,
        [PSCredential] $ServiceCredentials = $null,
        [String] $PoolName = "default",
        [String] $LocalAgentSource = $null,
        [String] $WorkFolder = "_work"
    )

    $PlainToken = $Token.GetNetworkCredential().Password
    $existingConfig = Get-ExistingConfig -AgentFolder $AgentFolder -Token $PlainToken

    if ($Ensure -eq "Present" -and $existingConfig.Agent) 
    {
        Write-Verbose "Agent is present as requested. Reconfiguring it now."
        Remove-Agent -ServerUrl $ServerUrl -Token $PlainToken -AgentFolder $AgentFolder
        Set-Agent -ServerUrl $ServerUrl -Token $PlainToken -AgentFolder $AgentFolder -PoolName $PoolName -AgentName $Name -ServiceCredentials $ServiceCredentials -LocalAgentSource $LocalAgentSource -WorkFolder $WorkFolder
        return
    }

    if ($Ensure -eq "Present" -and -not $existingConfig.Agent) 
    {
        Write-Verbose "Agent was requested to be present, but is absent. Configuring it now."
        Set-Agent -ServerUrl $ServerUrl -Token $PlainToken -AgentFolder $AgentFolder -PoolName $PoolName -AgentName $Name -ServiceCredentials $ServiceCredentials -LocalAgentSource $LocalAgentSource -WorkFolder $WorkFolder
        return
    }

    if ($Ensure -eq "Absent" -and $existingConfig.Agent) 
    {
        Write-Verbose "Agent was requested to be absent, but is present. Removing it now."
        Remove-Agent -ServerUrl $ServerUrl -Token $PlainToken -AgentFolder $AgentFolder
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

        [PSCredential] $Token,
        [PSCredential] $ServiceCredentials = $null,
        [String] $PoolName = "default",
        [String] $LocalAgentSource = $null,
        [String] $WorkFolder = "_work"
    )

    $PlainToken = $Token.GetNetworkCredential().Password

    $existingConfig = Get-ExistingConfig -AgentFolder $AgentFolder -Token $PlainToken 
    Write-Verbose "Found existing config $existingConfig"
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
            Write-Verbose "Requested agent name $Name does not match actual agent name $($existingConfig.Agent.agentName)."
            return $false
        }
        
        if ($WorkFolder -ne $existingConfig.Agent.workFolder)
        {
            Write-Verbose "Agent work folder does not match."
            return $false
        }
        
        $UserName = if ($ServiceCredentials) {$ServiceCredentials.UserName} else {"NT AUTHORITY\NETWORK SERVICE"}
        if ($UserName -ne $existingConfig.ServiceStartName)
        {
            Write-Verbose "Service start name does not match."
            return $false
        }
        
        if ($PoolName -ne $existingPoolName)
        {
            Write-Verbose "PoolName does not match."
            return $false
        }
        
        if ($ServerUrl.ToLower().Trim("/"," ") -ne $existingConfig.Agent.serverUrl.ToLower().Trim("/"," "))
        {
            Write-Verbose "Requested ServerUrl $ServerUrl does not match actual ServerUrl $($existingConfig.Agent.serverUrl)."
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