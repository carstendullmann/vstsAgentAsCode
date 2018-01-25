function Get-ExistingConfigPartFromFile($AgentFolder, $fileName)
{
    $filePath = Join-Path -Path $AgentFolder -ChildPath $fileName
    if (Test-Path $filePath)
    {
        $content = Get-Content -Path $filePath
        try
        {
            return $content | ConvertFrom-Json
        }
        catch
        {
            return $content
        }
    }

    return $null
}

function Get-AgentFromServer($ServerUrl, $Token, $poolId, $agentId)
{
    $authString = "AnyUserNameIsGoodForPAT:$Token"
    $authStringEncoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($authString))
    $requestUrl = "$ServerUrl/_apis/distributedtask/pools/$poolId/agents/$($agentId)?includeCapabilities=true"
    try
    {
        return Invoke-RestMethod -uri $requestUrl -Method Get -Headers @{"Authorization" = "Basic $authStringEncoded"}
    }
    catch
    {
        return $null
    }
}

function Get-PoolFromServer($ServerUrl, $Token, $poolId)
{
    $authString = "AnyUserNameIsGoodForPAT:$Token"
    $authStringEncoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($authString))
    $requestUrl = "$ServerUrl/_apis/distributedtask/pools/$poolId"
    try
    {
        return Invoke-RestMethod -uri $requestUrl -Method Get -Headers @{"Authorization" = "Basic $authStringEncoded"}
    }
    catch
    {
        return $null
    }
}

function Get-ExistingConfig($AgentFolder, $Token)
{
    # We currently assume fixed agent folders. To enable changing the agent folder, we would need to contact the server to check by the agent's name. Should be doable, but would be significantly more complicated.
    # Todo: Find out agent version (if not already in the agent from server config)
    $existingConfig = New-Object PSObject
    $existingConfig | Add-Member -Name "Agent" -MemberType NoteProperty -Value (Get-ExistingConfigPartFromFile -fileName ".agent" -AgentFolder $AgentFolder)
    $existingConfig | Add-Member -Name "Service" -MemberType NoteProperty -Value (Get-ExistingConfigPartFromFile -fileName ".service" -AgentFolder $AgentFolder)
    if ($existingConfig.Agent)
    {
        $existingConfig | Add-Member -Name "AgentFromServer" -MemberType NoteProperty -Value (Get-AgentFromServer -ServerUrl $existingConfig.Agent.serverUrl -Token $Token -poolId $existingConfig.Agent.poolId -agentId $existingConfig.Agent.agentId )
        $existingConfig | Add-Member -Name "PoolFromServer" -MemberType NoteProperty -Value (Get-PoolFromServer -ServerUrl $existingConfig.Agent.serverUrl -Token $Token -poolId $existingConfig.Agent.poolId)
    }

    return $existingConfig
}

function Set-Agent([System.Boolean] $Replace, $ServerUrl, $Token, $AgentFolder, $PoolName, $AgentName)
{
    # Replace: If we have same name but it is not our directory
    # Reconfigure: If we have any different (new) setting for existing agent
    
    If (-NOT (Test-Path $AgentFolder)) 
    {
        New-Item -Path $AgentFolder -ItemType Directory
    }
  
    $agentZip = $null
    if (-NOT (Test-Path (Join-Path -Path "$AgentFolder" -ChildPath "config.cmd"))) # did we do the agent download already? 
    {
        $agentZip = "$AgentFolder\agent.zip"
        # TODO: Local zip source
        Invoke-WebRequest -Uri "https://vstsagentpackage.azureedge.net/agent/2.126.0/vsts-agent-win-x64-2.126.0.zip" -OutFile $agentZip
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($agentZip, $AgentFolder)
    }

    $CommandArgs = @(
        "--url", $ServerUrl,
        "--unattended",
        "--auth", "PAT",
        "--token", $Token,
        "--pool", $PoolName,
        "--agent", $AgentName, 
        "--runAsService"
        # TODO: "--windowsLogonAccount myDomain\myUserName --windowsLogonPassword myPassword"
    )

    $CommandArgs

    if ($Replace)
    {
        Write-Verbose "Replacing existing agent."
        $CommandArgs += "--replace"
    }
  
    & "$AgentFolder\config.cmd" $CommandArgs

    # TODO: Check $LASTEXITCODE
  
    if ($agentZip)
    { 
        # Remove-Item $agentZip
    }
}

function Remove-Agent($ServerUrl, $Token, $AgentFolder)
{
    Write-Verbose "Removing existing agent."
    & "$AgentFolder\config.cmd" @("remove", "--url", $ServerUrl, "--auth", "PAT", "--token", $Token)
}
