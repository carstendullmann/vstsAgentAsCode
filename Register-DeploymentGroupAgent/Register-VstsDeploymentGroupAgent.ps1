param
(
    [String] $AgentFolder = "$env:SystemDrive\vsts\a1",
    [Parameter(Mandatory)][String] $DeploymentGroupName,
    [String] $AgentName = $env:COMPUTERNAME,
    [Parameter(Mandatory)][String] $VstsAccountName,
    [Parameter(Mandatory)][String] $VstsTeamProjectName,
    [Parameter(Mandatory)][String] $VstsPat
)
$ErrorActionPreference = "Stop"
If (-NOT 
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator"))
{ 
    throw "Administrator Privileges needed."
}
If (-NOT (Test-Path $AgentFolder))
{
    New-Item -Path $AgentFolder -ItemType Directory
}
Set-Location $AgentFolder

$agentZip = $null
if (-NOT (Test-Path (Join-Path -Path "$AgentFolder" -ChildPath "config.cmd"))) # did we do the agent download already?
{
    $agentZip = "$PWD\agent.zip"
    Invoke-WebRequest -Uri "https://vstsagentpackage.azureedge.net/agent/2.126.0/vsts-agent-win-x64-2.126.0.zip" -OutFile $agentZip
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory( $agentZip, "$PWD")
}

if (Test-Path (Join-Path -Path "$AgentFolder" -ChildPath ".\.agent"))
{
    Write-Output "Agent already configured."
    #.\config.cmd remove --auth PAT --token $VstsPat
}
else
{
    .\config.cmd --unattended --deploymentgroup --deploymentgroupname $DeploymentGroupName --agent $AgentName --runasservice --work '_work' --url "https://$VstsAccountName.visualstudio.com/" --projectname $VstsTeamProjectName --auth PAT --token $VstsPat --runAsService --windowsLogonAccount "NT AUTHORITY\SYSTEM" --replace 
}

if ($agentZip)
{ 
    Remove-Item $agentZip
}