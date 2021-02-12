param(
    [ValidateNotNullOrEmpty()]
    [String]$ModuleName,
    [String]$TestOneFile
)
Properties {
    $Ci = $env:ci -eq $true
    $StorageEmulatorPath = "C:\Program Files (x86)\Microsoft SDKs\Azure\Storage Emulator\AzureStorageEmulator.exe"
    $Root = git rev-parse --show-toplevel  
    if($TestOneFile)
    {
        if($TestOneFile -notlike "*.ps1")
        {
            write-warning "Can't test non-powershell files"
            throw "Can't test non-powershell files"
        }
        if($TestOneFile -like "*psakefile*")
        {
            write-warning "Ignoring psakefiles"
            throw "Ignoring psakefiles"
        }
        Write-host "Getting module of '$TestOneFile'"
        $dir = (get-item $TestOneFile).Directory
        :modulesearch While((gci $dir.fullname -Filter "*.psm1").count -lt 1 )
        {
            if($dir.FullName -eq $Root -or $dir.FullName -eq $dir.Root)
            {
                throw "Cannot search any further as ive reached the root of the project"
            }
            $dir = $dir.Parent
            # write-host $dir
        }
        # Write-host $dir
        $modulename = $dir.Name
    }

    $ModulePath = join-path $root "module/$modulename" -Resolve
    $ModuleFile = join-path $ModulePath "$modulename.psm1" -Resolve
    
    $TempFolder = Join-Path $env:TEMP "with.storage"
    $TempModulePath = Join-Path $env:TEMP "with.storage/$modulename"

    # $ModulePath = Join-Path $TempFolder $ModuleName
    # $ModuleFile = Join-Path $ModulePath "$ModuleName.psm1"
    # $pesterHelp = gci "$($psake.build_script_dir)/ci/pester"
}

task default -depends checkVersion
task build -depends default,pretest,compile
# task prep -depends checkVersion,CopyToTemp,Pester_addGeneralTestsToTemp

gci $psake.build_script_dir -Filter "psakefile.*.ps1"|%{
    Write-host "importing psakefile $_"
    & $_.FullName
}

task checkVersion {
    #check powershell version
    Assert ($PSVersionTable.PSVersion -ge 7.0.0) -failureMessage "build needs pwsh 7 or newer"

    #check dotnet version
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
