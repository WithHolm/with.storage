
task pretest -depends pester_prep,pester_pre_run,pester_disable

task posttest -depends pester_prep,pester_post_run,pester_disable

task pester_prep -depends default,pester_CheckStorageEmulator,pester_enable,Pester_setupConString_local,Pester_setupConString_ci

task pester_pre_run -action {
    $env:pester_module_name = $modulename
    $env:pester_module_fullname = $modulepath
    #Set path of where to find pester help files
    $pesterCI = join-path $root 'ci/pester' -Resolve

    #import helpercommands
    gci $pesterCI -file -Recurse -Filter "*.pester.ps1"|%{
        . $_.fullname
    }

    #import module
    write-host "importing module $modulepath"
    if(get-module $modulename)
    {
        get-module $modulename|remove-module
    }
    ipmo $modulepath -Force

    module $modulename

    #add pesterfiles. safest way as i cannot know what cd im in right now
    if($TestOneFile)
    {
        $File = get-item $TestOneFile
        if($file.BaseName -like "*.tests")
        {
            $TestFileName = $File.name
        }
        else {
            $TestFileName = "$($File.BaseName).tests.ps1"
        }

        $TestFiles = Get-ChildItem $ModulePath -Recurse -Filter $TestFileName -File

        if($null -eq $TestFiles)
        {
            Throw "Could not find a pester test for the file $testonefile. should be '$($File.BaseName).tests.ps1'"
        }

        invoke-pester -path $TestFiles -output detailed #-Show All  #-PassThru -
    }
    else {
        $TestFiles = Get-ChildItem $ModulePath -Recurse -Filter "*.tests.ps1" -File
        $TestFiles += Get-ChildItem $pesterCI -Recurse -Filter "*.pretests.ps1" -File 

        if([string]::IsNullOrEmpty($env:PesterStorageConnectionString))
        {
            throw "env:PesterStorageConnectionString is not set. cannot test"
        }
        write-host "testing tag '$tag'"
        
        $pester = invoke-pester $TestFiles -PassThru -Tag $tag
        if ($pester.FailedCount -gt 0)
        {
            throw "$($pester.FailedCount) pester tests failed"
        }
        else
        {
            $total += $pester.TotalCount
        }
        # $total = 0
        # # $TestFiles 
        # foreach ($tag in 'module', "cmdlet")
        # {
        # }
        Write-Host "$total tests completed. no erors found!"
    }

}

task pester_post_run {

}

# task Pester_addGeneralTestsToTemp{
#     $pesterfiles = gci $psake.build_script_dir -Filter "*.tests.ps1" -File
#     $Destination = (join-path $TempFolder $ModuleName)
#     Write-host "Copying $(@($pesterfiles).count) pester files from root to '$Destination'"
#     $pesterfiles|%{
#         $_|copy-item -Destination $Destination
#     }
# }

task pester_enable { 
    $global:pesteractive = $true 
}

task pester_disable { 
    $global:pesteractive = $false 
}

task pester_CheckStorageEmulator -precondition { $env:CI -ne $true } -action {
    if (test-path $StorageEmulatorPath)
    {
        # $PSVersionTable
        $statusSb = { 
            exec -cmd { & $StorageEmulatorPath status } | 
                Where-Object { $_ -like "*:*" } | 
                    ConvertFrom-StringData -Delimiter ':' 
        }

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