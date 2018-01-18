Configuration SampleConfig
{
    Import-DscResource cVstsAgent
    VstsAgent MyAgent
    {
        Name = "MyMachine-Agent1"
        AgentFolder = "C:\vsts-agent\5"
        Token = "4gst5krr3j26rhrwcqao7uqg7ldijc7bmm6rl3b4ukbunt55z2za"
        ServerUrl = "https://$VstsAccountName.visualstudio.com/"
        Ensure = "Present"
    }
}