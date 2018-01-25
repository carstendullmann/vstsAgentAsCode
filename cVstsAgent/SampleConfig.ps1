Configuration SampleConfig
{
    param
    (
        $Token
    )

    Import-DscResource -ModuleName cVstsAgent
    
    cVstsAgent MyAgent
    {
        Name = "MyMachine-Agent1"
        AgentFolder = "C:\vsts-agent\5"
        Token = $Token
        ServerUrl = "https://cadull.visualstudio.com/"
        PoolName = "default"
        Ensure = "Present"
    }
}