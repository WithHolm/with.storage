task compile -depends prep,createManifest

task cleanModule {
    write-host "cleaning $ModulePath for pester files"
    gci $ModulePath -Filter "*tests.ps1" -File -Recurse|Remove-Item -Recurse
    gci $ModulePath -Directory -Recurse|?{(gci $_.FullName -Force).count -eq 0}|remove-item -Force
    gci $ModulePath -Filter ".nuget"|Remove-Item
}

task createManifest -depends cleanmodule {
    $TemplateFile = join-path $ModulePath "template.psd1"
    $moduleFile = get-item $ModuleFile
    if(!(test-path $TemplateFile))
    {
        New-ModuleManifest -Path $TemplateFile -RootModule $moduleFile.Name
    }
    $datafile = Import-PowerShellDataFile -Path $TemplateFile

    #Get commands to export
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

    Write-host "$($exportcommands.count) commands exported"
    if(!$datafile.CmdletsToExport)
    {
        $datafile.CmdletsToExport = @()
    }

    if(!$datafile.FunctionsToExport)
    {
        $datafile.FunctionsToExport = @()
    }

    $datafile.FunctionsToExport += $datafile.CmdletsToExport += @($ExportCommands)

    #Add psData
    $datafile.privatedata.PSData.ProjectUri = "https://github.com/withholm/with.storage"

    if($datafile.RequiredModules)
    {
        $datafile.privatedata.PSData.ExternalModuleDependencies = $datafile.RequiredModules
    }

    #Make sure the psdata is present in the main object
    $datafile.privatedata.PSData.getenumerator().foreach{
        $datafile.$($_.name) = $_.value
    }

    $datafile.privatedata.remove('PSdata')
    $datafile.path = (join-path $ModulePath "$($moduleFile.BaseName).psd1")

    New-ModuleManifest @datafile

    get-item $TemplateFile|Remove-Item
}