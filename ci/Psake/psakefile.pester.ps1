task test -depends pester_CheckStorageEmulator,pester_enable,Pester_setupConString_local,Pester_setupConString_ci,pester_run,pester_disable

task pester_run -action {
    $env:pester_test_folder = 
    $pesterHelp|?{$_.name -like "*.ps1"}|%{
        . $_.fullname
    }

    write-host "importing module file $ModuleFile"
    if(get-module $modulename)
    {
        get-module $modulename|remove-module
    }
    ipmo $ModuleFile -Force
    # Write-host "Invoking pester on tag 'module'"
    # invoke-pester -Script $ModulePath -tag 'Module'

    # $TestFiles = Get-ChildItem $ModulePath -Recurse -Filter "*.tests.ps1" -File
    $total = 0
    foreach ($tag in 'module', "cmdlet")
    {
        if([string]::IsNullOrEmpty($env:PesterStorageConnectionString))
        {
            throw "env:PesterStorageConnectionString is not set. cannot test"
        }
        write-host "testing '$tag'"
        
        $pester = invoke-pester $ModulePath -PassThru -Tag $tag
        if ($pester.FailedCount -gt 0)
        {
            throw "$tag tests: $($pester.FailedCount) pester tests failed"
        }
        else
        {
            $total += $pester.TotalCount
        }
    }
    Write-Host "$total tests completed. no erors found!"
}

task Pester_addGeneralTestsToTemp{
    $pesterfiles = gci $psake.build_script_dir -Filter "*.tests.ps1" -File
    $Destination = (join-path $TempFolder $ModuleName)
    Write-host "Copying $(@($pesterfiles).count) pester files from root to '$Destination'"
    $pesterfiles|%{
        $_|copy-item -Destination $Destination
    }
}

task pester_enable { 
    $global:pesteractive = $true 
}

task pester_disable { 
    $global:pesteractive = $false 
}

task pester_CheckStorageEmulator -precondition { $env:CI -ne $true } -action {
    if (test-path $StorageEmulatorPath)
    {
        $statusSb = { exec -cmd { & $StorageEmulatorPath status } | Where-Object { $_ -like "*:*" } | ConvertFrom-StringData -Delimiter ':' }
        $status = $statusSb.Invoke()
        #if its not started
        if (![bool]::Parse($status.isrunning))
        {
            Write-host "starting storage emulator"
            exec -cmd { & $StorageEmulatorPath start }

            start-sleep -Seconds 1

            Write-host "Confirming that its started"
            $status = $statusSb.Invoke()
            if (![bool]::Parse($status.isrunning))
            {
                throw "Cannot start storage emulator"
            }
        }
        else {
            Write-host "Storage Emulator is running"
        }
    }
    else
    {
        Throw "Could not find Azure storage Emulator at given location: '$StorageEmulatorPath'. please install: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-emulator"
    }
}

task Pester_setupConString_local -precondition  { $env:CI -ne $true } -action {
    Write-host "Setting up connection string to use "
    # Standard key to storage emulator
    $keyhash = [ordered]@{
        DefaultEndpointsProtocol = "http"
        AccountName              = 'devstoreaccount1'
        AccountKey               = 'Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw=='
        BlobEndpoint             = "http://127.0.0.1:10000/devstoreaccount1"
        TableEndpoint            = "http://127.0.0.1:10002/devstoreaccount1"
        QueueEndpoint            = "http://127.0.0.1:10001/devstoreaccount1"
    }
    $env:PesterStorageConnectionString = ($keyhash.GetEnumerator() | % { 
            "$($_.Key)=$($_.Value);" }) -join ""
}

task Pester_setupConString_ci -precondition {$env:CI -eq $true} -action {
    $env:PesterStorageConnectionString = $env:StorageConnectionString
}