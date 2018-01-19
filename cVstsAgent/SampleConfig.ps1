Configuration SampleConfig
{
    param
    (
        $Token
    )

    Import-DscResource cVstsAgent
    VstsAgent MyAgent
    {
        Name = "MyMachine-Agent1"
        AgentFolder = "C:\vsts-agent\5"
        Token = $Token
        ServerUrl = "https://$VstsAccountName.visualstudio.com/"
        Ensure = "Present"
    }
}