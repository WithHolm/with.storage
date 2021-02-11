param(
    [ValidateNotNullOrEmpty()]
    [String]$ModuleName
)
Properties {
    $InformationPreference = "contiune"
}
Properties {
    $TempFolder = Join-Path $env:TEMP (split-path $psake.build_script_dir -Leaf)
    $StorageEmulatorPath = "C:\Program Files (x86)\Microsoft SDKs\Azure\Storage Emulator\AzureStorageEmulator.exe"
    $ModulePath = Join-Path $TempFolder $ModuleName
    $ModuleFile = Join-Path $ModulePath "$ModuleName.psm1"
    $pesterHelp = gci "$($psake.build_script_dir)/ci/pester"
}

task default 

task build -depends prep,test,compile
task prep -depends checkVersion,CopyToTemp,Pester_addGeneralTestsToTemp

gci $psake.build_script_dir -Filter "psakefile.*.ps1"|%{
    Write-host "importing psakefile $_"
    & $_.FullName
}

task checkVersion {
    Assert ($PSVersionTable.PSVersion -ge 7.0.0) -failureMessage "build needs pwsh 7 or newer"

    try
    {
        if ((Get-PSDrive 'HKLM' -ErrorAction Ignore) -and (-not (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\' -ErrorAction Stop | Get-ItemPropertyValue -ErrorAction Stop -Name Release | Where { $_ -ge 461808 })))
        {
            throw ".NET Framework versions lower than 4.7.2 are not supported in this module.  Please upgrade to .NET Framework 4.7.2 or higher."
        }
    }
    catch [System.Management.Automation.DriveNotFoundException]
    {
        Write-host ".NET Framework version check failed."
    }
}

task copyToTemp{
    if (!(Test-Path $TempFolder))
    {
        Write-Host "Creating '$TempFolder'"
        New-Item $TempFolder -ItemType Directory | Out-Null
    }
    else
    {
        Write-Host "Cleaning '$TempFolder'"
        Get-ChildItem $TempFolder -Force | remove-item -Recurse -Force
    }
    $ModuleDir = gci $($psake.build_script_dir) -Filter "$ModuleName.psm1" -Force -Recurse -File|%{$_.Directory}
    if(@($ModuleDir).count -ne 1)
    {
        throw "Was suppoed to find one '$modulename.psm1' file. found $(@($ModuleDir).count)"
    }
    else {
        Write-host "copying from '$($ModuleDir.FullName)' to '$TempFolder'"
        $ModuleDir| copy-item -Container -Destination $ModulePath -Recurse -Force
    }
}