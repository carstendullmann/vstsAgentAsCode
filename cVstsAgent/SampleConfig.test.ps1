Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName "SampleConfig.test.settings.psd1" -BindingVariable testSettings | Out-Null
# That .psd1 contains secrets and is not committed to the git repository. Will need to be created individually like this:
#  @{
#     PAT = "myPAT"
#  }

& $PSScriptRoot\Build-Resource.ps1
& $PSScriptRoot\Install-Resource.ps1

. $PSScriptRoot\SampleConfig.ps1

$ConfigurationData = @{
    AllNodes = @(    
        @{ 
            NodeName = "localhost"
            CertificateFile = "$PSScriptRoot\DscPublicKey.cer" # Again not committed to the repo. Will need to be created individually like this:
            # $cert = New-SelfSignedCertificate -Type DocumentEncryptionCertLegacyCsp -DnsName 'DscEncryptionCert' -HashAlgorithm SHA256
            # $cert | Export-Certificate -FilePath "$env:temp\DscPublicKey.cer" -Force
            # $cert.Thumbprint # This will be used as the CertificateID
            # # See https://docs.microsoft.com/en-us/powershell/dsc/secureMOF
        }
    ) 
}

$Token = New-Object PSCredential ("PAT", (ConvertTo-SecureString $testSettings.PAT -Force -AsPlainText))
$ServiceCreds = New-Object PSCredential($testSettings.Username,(ConvertTo-SecureString $testSettings.Password -Force -AsPlainText))
SampleConfig -ConfigurationData $ConfigurationData -Token $Token -ServiceCreds $ServiceCreds -OutputPath $PSScriptRoot\SampleConfig

Set-DscLocalConfigurationManager -Path $PSScriptRoot\SampleConfig -Verbose 
Start-DscConfiguration -Path $PSScriptRoot\SampleConfig -Wait -Verbose -Force