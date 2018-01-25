Configuration SampleConfig
{
    param
    (
        $Token
    )

    Import-DscResource -ModuleName cVstsAgent
    
    cVstsAgent MyAgent
    {
        Name = "TestAgent10"
        AgentFolder = "C:\vsts-agent\9"
        Token = $Token
        ServerUrl = "https://cadull.visualstudio.com/"
        PoolName = "default"
        Ensure = "Present"
    }
}