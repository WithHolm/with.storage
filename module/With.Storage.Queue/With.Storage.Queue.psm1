
#used for loading all file when developing
if(test-path (join-path $PSScriptRoot 'Template.psd1'))
{
    #loads all ps1 files except the ones names .tests.ps1 or is in a beta folder
    gci $PSScriptRoot -Recurse -Filter '*.ps1'|?{$_.name -notlike "*.tests.ps1"}|?{$_.Directory.name -notin 'beta'}|%{
        . $_.FullName
    }
}

Set-StrictMode -Version Latest
function Test-DotNet
{
    try
    {
        if ((Get-PSDrive 'HKLM' -ErrorAction Ignore) -and (-not (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\' -ErrorAction Stop | Get-ItemPropertyValue -ErrorAction Stop -Name Release | Where { $_ -ge 461808 })))
        {
            throw ".NET Framework versions lower than 4.7.2 are not supported in this module.  Please upgrade to .NET Framework 4.7.2 or higher."
        }
    }
    catch [System.Management.Automation.DriveNotFoundException]
    {
        Write-Verbose ".NET Framework version check failed."
    }
}

if ($true -and ($PSEdition -eq 'Desktop'))
{
    if ($PSVersionTable.PSVersion -lt [Version]'5.1')
    {
        throw "PowerShell versions lower than 5.1 are not supported in this module. Please upgrade to PowerShell 5.1 or higher."
    }

    Test-DotNet
}