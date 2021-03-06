

Configuration SampleConfig
{
    param
    (
        [pscredential] $Token,
        [PSCredential] $ServiceCreds
    )

    Import-DscResource -ModuleName cVstsAgent

    Node "localhost"
    {

        cVstsAgent MyAgent
        {
            Name               = "TestAgent13"
            AgentFolder        = "C:\vsts-agent\13"
            Token              = $Token
            ServerUrl          = "https://cadull.visualstudio.com/"
            PoolName           = "default"
            Ensure             = "Present"
            WorkFolder         = "C:\vsts-agent\workFolder13"
            # ServiceCredentials = $ServiceCreds
            LocalAgentSource   = "C:\vsts-agent\agentSource\agent.zip"
        }

        cVstsAgent MyAgent5
        {
            Name        = "TestAgent5"
            AgentFolder = "C:\vsts-agent\5"
            Token       = $Token
            ServerUrl   = "https://cadull.visualstudio.com/"
            PoolName    = "default"
            Ensure      = "Absent"
        }

        cVstsAgent MyAgent6
        {
            Name        = "TestAgent6"
            AgentFolder = "C:\vsts-agent\6"
            Token       = $Token
            ServerUrl   = "https://cadull.visualstudio.com/"
            PoolName    = "default"
            Ensure      = "Absent"
        }

        LocalConfigurationManager
        {
            CertificateID = "8B9378195FBD08E2C20EC272B02C80090D842763"
            # Cert and CertID created like this:
            # $cert = New-SelfSignedCertificate -Type DocumentEncryptionCertLegacyCsp -DnsName 'DscEncryptionCert' -HashAlgorithm SHA256
            # $cert | Export-Certificate -FilePath "$env:temp\DscPublicKey.cer" -Force
            # $cert.Thumbprint # This will be used as the CertificateID
            # # See https://docs.microsoft.com/en-us/powershell/dsc/secureMOF
        }
    }
}