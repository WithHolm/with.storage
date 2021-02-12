task compile -depends module_copyToTemp,module_clean,module_defineManifest
task module_defineManifest -depends module_manifest_load,module_manifest_set_exportcommands,module_manifest_set_otherinfo,module_manifest_save

task module_clean {
    write-host "cleaning $TempModulePath for pester files"
    gci $TempModulePath -Filter "*tests.ps1" -File -Recurse|Remove-Item -Recurse
    gci $TempModulePath -Directory -Recurse|?{(gci $_.FullName -Force).count -eq 0}|remove-item -Force
    gci $TempModulePath -Filter ".nuget",".dev"|Remove-Item
}

task module_copyToTemp{
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

    get-item $ModulePath|copy-item -Destination $TempFolder -Recurse -Force
}

task module_test_load{
    ipmo $TempModulePath -Force
    module $modulename
}

task module_manifest_load{
    $TemplateFile = gci $TempModulePath -Filter "*.psd1"|select -first 1
    if(!$TemplateFile)
    {
        throw "Could not find a psd1 file in $TempModulePath"
    }
    if(!(test-path $TemplateFile))
    {
        New-ModuleManifest -Path $TemplateFile.FullName -RootModule "$ModuleName.psm1"
    }
    $Script:Manifest = Import-PowerShellDataFile -Path $TemplateFile.FullName
}

task module_manifest_save -depends module_import_manifest{
    $datafile = $script:Manifest.clone()
    $datafile.privatedata.remove('PSdata')
    $datafile.path = (join-path $TempModulePath "$modulename.psd1")
    New-ModuleManifest @datafile
    gci $TempModulePath -Filter "*.psd1"|?{$_.name -ne "$modulename.psd1"}|remove-item
}

task module_manifest_set_exportcommands -depends module_import_manifest{
    #nothing to do with this yet
    $privCommands = gci $TempModulePath -Filter "*.ps1" -Recurse|?{$_.Directory.name -eq "private"}

    $pubCommands = gci $TempModulePath -Filter "*.ps1" -Recurse|?{$_.Directory.name -eq "public"}

    $exportcommands = $pubCommands|%{
        # Write-host $_.FullName
        gc $_.FullName|?{$_ -like "function *"}|%{
            $regex = "[fF]unction\W(?'funcName'\w*-\w*)\W{0,1}({|)"
            if($_ -match $regex)
            {
                $matches['funcName'].trim()
            }
        }
    }

    if(!$script:Manifest.CmdletsToExport)
    {
        $script:Manifest.CmdletsToExport = @()
    }

    if(!$script:Manifest.FunctionsToExport)
    {
        $script:Manifest.FunctionsToExport = @()
    }

    $script:Manifest.FunctionsToExport += $script:Manifest.CmdletsToExport += @($ExportCommands)
}

task module_manifest_set_otherinfo -depends module_import_manifest{

    #Add project site
    $script:Manifest.privatedata.PSData.ProjectUri = "https://github.com/withholm/with.storage"

    #add psgallery info about external required modules
    if($script:Manifest.RequiredModules)
    {
        $script:Manifest.privatedata.PSData.ExternalModuleDependencies = $script:Manifest.RequiredModules
    }

    #add version
    $script:Manifest.ModuleVersion = (get-date).ToString("yy.mm.dd")
}