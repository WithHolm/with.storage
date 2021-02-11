task compile -depends prep,module_defineManifest
task module_defineManifest -depends module_import_manifest,module_set_exportcommands,module_set_otherinfo,module_save_manifest


task module_clean {
    write-host "cleaning $ModulePath for pester files"
    gci $ModulePath -Filter "*tests.ps1" -File -Recurse|Remove-Item -Recurse
    gci $ModulePath -Directory -Recurse|?{(gci $_.FullName -Force).count -eq 0}|remove-item -Force
    gci $ModulePath -Filter ".nuget"|Remove-Item
}

task module_import_manifest{
    $TemplateFile = join-path $ModulePath "template.psd1"
    $moduleFile = get-item $ModuleFile
    if(!(test-path $TemplateFile))
    {
        New-ModuleManifest -Path $TemplateFile -RootModule $moduleFile.Name
    }
    $Script:Manifest = Import-PowerShellDataFile -Path $TemplateFile
}

task module_save_manifest -depends module_import_manifest{
    $datafile = $script:Manifest.clone()
    $datafile.privatedata.remove('PSdata')
    $datafile.path = (join-path $ModulePath "$($moduleFile.BaseName).psd1")
    New-ModuleManifest @datafile
    get-item $TemplateFile|Remove-Item
}

task module_set_exportcommands -depends module_import_manifest{
    #nothing to do with this yet
    $privCommands = gci $ModulePath -Filter "*.ps1" -Recurse|?{$_.Directory.name -eq "private"}

    $pubCommands = gci $ModulePath -Filter "*.ps1" -Recurse|?{$_.Directory.name -eq "public"}

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

task module_set_otherinfo -depends module_import_manifest{

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

task module_test_manifest {

}