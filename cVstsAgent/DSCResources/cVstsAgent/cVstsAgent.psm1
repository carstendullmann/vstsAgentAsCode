# See https://docs.microsoft.com/en-us/powershell/dsc/authoringresourcemof
# https://docs.microsoft.com/en-us/powershell/dsc/resourceauthoringchecklist

# DSC uses the Get-TargetResource function to fetch the status of the resource instance specified in the parameters for the target machine
function Get-TargetResource {
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

        [string]$Token
    )

    $getTargetResourceResult = $null

    <# Insert logic that uses the mandatory parameter values to get the website and assign it to a variable called $Website #>
    <# Set $ensureResult to "Present" if the requested website exists and to "Absent" otherwise #>



    $getTargetResourceResult = @{
        Ensure      = $ensureResult
        Name        = ""
        AgentFolder = ""
        ServerUrl   = ""
    }

    return $getTargetResourceResult
}

# The Set-TargetResource function is used to create, delete or configure a website on the target machine. 
function Set-TargetResource {
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

        [string]$Token
    )

    <# If Ensure is set to "Present" and the website specified in the mandatory input parameters does not exist, then create it using the specified parameter values #>
    <# Else, if Ensure is set to "Present" and the website does exist, then update its properties to match the values provided in the non-mandatory parameter values #>
    <# Else, if Ensure is set to "Absent" and the website does not exist, then do nothing #>
    <# Else, if Ensure is set to "Absent" and the website does exist, then delete the website #>
}

function Test-TargetResource {
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

        [string]$Token
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    #Include logic to 
    $result = [System.Boolean]
    #Add logic to test whether the website is present and its status mathes the supplied parameter values. If it does, return true. If it does not, return false.
    $result
}