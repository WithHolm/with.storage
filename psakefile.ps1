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
    $BaseName = "With.Storage"
}

task default 

task prep -depends checkPowerShellVersion

task BuildModule -depends prep,CopyToTemp,createManifest

& "$($psake.build_script_dir)\psakefile.modulebuild.ps1"

task checkPowerShellVersion {
    Assert ($PSVersionTable.PSVersion -ge 7.0.0) -failureMessage "build needs pwsh 7 or newer"
}

task CopyToTemp{
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
        $ModuleDir| copy-item -Container -Destination (join-path $TempFolder $ModuleName) -Recurse -Force
    }
}

#-depends checkPowerShellVersion, test, build, publish

# task build -depends checkPowerShellVersion, build_clean_pester, build_create_manifest, build_create_docs

# task test -depends checkPowerShellVersion, pester_CheckStorageEmulator, pester_enable, pester_import, pester, pester_disable


task pester_enable { 
    $global:pesteractive = $true 
}

task pester_disable { 
    $global:pesteractive = $false 
}

task pester_import { 
    Write-Host "importing $ModulePath"
    Import-Module $ModulePath -Force
}

# task pester_CheckStorageEmulator -precondition { $env:CI -ne $true } {
#     if (test-path $StorageEmulatorPath)
#     {
#         # command ConvertFrom-StringData
#         # command ConvertFrom-StringData|select Parametersets
#         #get status, convert output to a object
#         $statusSb = { exec -cmd { & $StorageEmulatorPath status } | Where-Object { $_ -like "*:*" } | ConvertFrom-StringData -Delimiter ':' }
#         $status = $statusSb.Invoke()
#         #if its not started
#         if (![bool]::Parse($status.isrunning))
#         {
#             Write-host "starting storage emulator"
#             exec -cmd { & $StorageEmulatorPath start }

#             start-sleep -Seconds 1

#             Write-host "Confirming that its started"
#             $status = $statusSb.Invoke()
#             if (![bool]::Parse($status.isrunning))
#             {
#                 throw "Cannot start storage emulator"
#             }
#         }
#     }
#     else
#     {
#         Throw "Could not find Azure storage Emulator at given location: '$StorageEmulatorPath'. please install: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-emulator"
#     }
# }

# task SetupLocalConnectionString { $env:CI -ne $true } {
#     # Standard key to storage emulator
#     $keyhash = [ordered]@{
#         DefaultEndpointsProtocol = "http"
#         AccountName              = 'devstoreaccount1'
#         AccountKey               = 'Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw=='
#         BlobEndpoint             = "http://127.0.0.1:10000/devstoreaccount1"
#         TableEndpoint            = "http://127.0.0.1:10002/devstoreaccount1"
#         QueueEndpoint            = "http://127.0.0.1:10001/devstoreaccount1"
#     }
#     $env:PesterStorageConnectionString = ($keyhash.GetEnumerator() | % { 
#             "$($_.Key)=$($_.Value);" }) -join ""
# }

# task Pester -action {

#     $test = @{
#         Path = (join-path $psake.build_script_dir "GeneralPester.ps1")
#         Parameters = @{module = [System.IO.FileInfo]$ModuleFile } 
#     }
#     # $test|ConvertTo-Json

#     Invoke-Pester -Script $test

#     $TestFiles = Get-ChildItem $ModulePath -Recurse -Filter "*.tests.ps1" -File
#     $total = 0
#     foreach ($tag in 'module', "cmdlet")
#     {
#         write-host "testing '$tag'"
        
#         $pester = invoke-pester $TestFiles.fullname -PassThru -Tag $tag -Output Detailed
#         if ($pester.FailedCount -gt 0)
#         {
#             throw "$tag tests: $($pester.FailedCount) pester tests failed"
#         }
#         else
#         {
#             $total += $pester.TotalCount
#         }
#     }
#     Write-Host "$total tests completed. no erors found!"

# }

# task build_clean_tempfolder {
#     if (!(Test-Path $TempFolder))
#     {
#         Write-Host "Creating '$TempFolder'"
#         New-Item $TempFolder -ItemType Directory | Out-Null
#     }
#     else
#     {
#         Write-Host "Cleaning '$TempFolder'"
#         Get-ChildItem $TempFolder -Force | remove-item -Recurse -Force
#     }
# }

# task build_copyto_temp -depends build_clean_tempfolder {
#     Write-host "copying from '$($psake.build_script_dir)' to '$TempFolder'"
#     gci $($psake.build_script_dir) -Force | copy-item -Destination $TempFolder -Recurse -Force
# }

# task build_clean_pester -depends build_copyto_temp -action {
#     Write-host "Removing pester files"
#     gci $TempFolder -Filter "tests" -Directory -Recurse | Remove-Item -Recurse -Force

#     write-host "removing pester helper files"
#     gci $TempFolder -Filter "*.pesterhelp.ps1" -Directory -Recurse | remove-item -Recurse -Force

#     write-host "removing module test file"
#     gci $TempFolder -Filter "*.moduletests.ps1" | Remove-Item
# }


# task build_Create_Manifest {
#     $ManifestParam = @{
#         RootModule      = "$ModuleName.psm1"
#         guid            = '5b4635f7-b0d9-4adc-95e1-be09e69f521d'
#         ModuleVersion   = [version](@("0", (date -f 'yyMM'), "0") -join '.')
#         Path            = (join-path $psake.build_script_dir "$ModuleName.psd1")
#         CompanyName     = "Withholm"
#         Copyright       = "Philip Meholm"
#         Description     = "Module to quickly connect with azure storage services"
#         RequiredModules = @(
#             "Az.Storage"
#             "Az.Accounts"
#             "azTable"
#             "unicode"
#         )
#         PrivateData     = @{
#             PSData = @{
#                 ProjectUri = 'https://github.com/WithHolm/FunctionsModule'
#             }
#         }
#     }
#     New-ModuleManifest @ManifestParam
# }

# task build_create_docs {
# }

# task publish {
# }