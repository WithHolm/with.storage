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
    $pesterHelp = gci "$($psake.build_script_dir)/ci/pester"
}

task default 

task build -depends prep,test,compile
task prep -depends checkPowerShellVersion,CopyToTemp,Pester_addGeneralTestsToTemp

gci $psake.build_script_dir -Filter "psakefile.*.ps1"|%{
    Write-host "importing $_"
    & $_.FullName
}

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
        $ModuleDir| copy-item -Container -Destination ModulePath -Recurse -Force
    }
}

#-depends checkPowerShellVersion, test, build, publish

# task build -depends checkPowerShellVersion, build_clean_pester, build_create_manifest, build_create_docs

# task test -depends checkPowerShellVersion, pester_CheckStorageEmulator, pester_enable, pester_import, pester, pester_disable

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