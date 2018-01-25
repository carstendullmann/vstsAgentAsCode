# See https://docs.microsoft.com/en-us/powershell/dsc/authoringresourcemof
# https://docs.microsoft.com/en-us/powershell/dsc/resourceauthoringchecklist

# Module manifest for module 'cVstsAgent'
@{
    # Script module or binary module file associated with this manifest.
    # RootModule = ''
    
    # Version number of this module.
    ModuleVersion = '0.1.0.0'
    
    # ID used to uniquely identify this module
    GUID = '9B6E6A61-449F-4876-B2BA-C569387651B9'
    
    # Author of this module
    Author = 'Carsten Düllmann'
    
    # Company or vendor of this module
    CompanyName = ''
    
    # Copyright statement for this module
    Copyright = ''
    
    # Description of the functionality provided by this module
    Description = 'This module can configure VSTS or TFS distributed agents for building, releasing or testing software.'
    
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '4.0'
    
    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion = '4.0'
    
    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()
    
    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @("cVstsAgent.psm1")
    
    # Functions to export from this module
    FunctionsToExport = @("Get-TargetResource", "Set-TargetResource", "Test-TargetResource")
    
    # Cmdlets to export from this module
    #CmdletsToExport = '*'
    
    # HelpInfo URI of this module
    # HelpInfoURI = ''
    }