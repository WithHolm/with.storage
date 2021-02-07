function Restore-NugetPackage
{
    [CmdletBinding()]
    param (
        $ConfigFile
    )
    
    begin
    {
        Set-alias -Name "_nuget" -Value "$PSScriptRoot/nuget.exe" -Description "Nuget cli" -Force -Scope "script"
        Write-host "Getting config '$ConfigFile'"
        $config = Get-Content -Raw $ConfigFile | convertfrom-json

        #InstallDirectory
        $InstallDirectory = $Config.options.directory
        if ([string]::IsNullOrEmpty($InstallDirectory))
        {
            Throw "No install directory defined."
        }
        else
        {
            $ConfigDir = (get-item $ConfigFile).Directory.FullName
            $InstallDirectory = New-item -Path (join-path $ConfigDir $InstallDirectory) -ItemType Directory -Force -ErrorAction Stop
        }
    }
    
    process
    {
        Write-host "Going through $($config.packages.count) packages"
        foreach ($package in $Config.packages)
        {
            _nuget install $($package.name) -version $package.version -OutputDirectory $InstallDirectory.FullName -PackageSaveMode "nuspec;nupkg"
        }
        
    }
    
    end
    {
        
    }
}

Restore-NugetPackage -Config "C:\git\with.storage\With.Storage.Cosmos.Mongo\nuget.config.json"