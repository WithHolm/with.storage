function Import-DotnetPackages
{
    [CmdletBinding()]
    param (
        $Path,
        
        $ProjectTag = "ImportNuget",

        [parameter(ParameterSetName = "FrameworkVersion")]
        [parameter(ParameterSetName = "Framework")]
        [parameter(ParameterSetName = "nugetfiles")]
        [switch]$FromDotNuget,
        
        [parameter(ParameterSetName = "Framework")]
        [ValidateSet(
            ".NET 5",
            ".NET Standard",
            ".NET Core",
            ".NET Framework"
        )]
        [String]$Framework,

        [parameter(ParameterSetName = "FrameworkVersion")]
        [ValidateSet(
            "netstandard2.1",
            "netstandard2.0",
            "netstandard1.6",
            "netstandard1.5",
            "netstandard1.4",
            "netstandard1.3",
            "netstandard1.2",
            "netstandard1.1",
            "netstandard1.0",
            "netcoreapp3.1",
            "netcoreapp3.0",
            "netcoreapp2.2",
            "netcoreapp2.1",
            "netcoreapp2.0",
            "netcoreapp1.1",
            "netcoreapp1.0",
            "net5.0*",
            "net48",
            "net472",
            "net471",
            "net47",
            "net462",
            "net461",
            "net46",
            "net452",
            "net451",
            "net45",
            "net403",
            "net40",
            "net35",
            "net20",
            "net11"
        )]
        $FrameworkVersion
    )
    begin
    {
        #check if dotnet cmdlet is present in powershell. it usually is if its installed
        $dotnet = command dotnet
        if (!$dotnet)
        {
            Throw "dotnet not installed"
        }


        #Setting up base
        $tempFolder = join-path $env:TEMP "$ProjectTag`_dotnet"
        $projectfilePath = join-path $tempFolder "$ProjectTag.csproj"
        if (!(test-path $tempFolder))
        {
            Write-Verbose "Creating temp dir '$tempfolder'"
            new-item $tempFolder -ItemType Directory | Out-Null
        }

        $CreateNewProject = $false
        if (test-path $projectfilePath)
        {
            $ProjectFile = [xml](get-content $projectfilePath)

            #if frameworkversion is defined in arguments, 
            #i need to check if its the same version as is in the project
            #if its not the same, build and restore will fail, or not get the correct dlls later on
            if (![string]::IsNullOrEmpty($FrameworkVersion))
            {
                $CurrentFrameworkVersion = $ProjectFile.project.propertygroup.TargetFramework
                if ($CurrentFrameworkVersion -ne $FrameworkVersion)
                {
                    Write-Verbose "Target version defined is not the same as in the project. recreate. Old: $CurrentFrameworkVersion, New: $FrameworkVersion"
                    $CreateNewProject = $true
                }
            }
            else
            {
                $CreateNewProject = $false
            }
        }
        else {
            Write-Verbose "No project found"
            $CreateNewProject = $true
        }
        Write-verbose "Project path is $tempFolder"

        if ($CreateNewProject)
        {
            gci $tempFolder | remove-item -Recurse -Force
            if(!$Framework -and !$FrameworkVersion)
            {
                $FrameWork = [System.Runtime.InteropServices.RuntimeInformation, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]::FrameworkDescription

                $FrameworkVersion = 'netstandard2.1'
            }

            if ([String]::IsNullOrEmpty($FrameworkVersion))
            {
                $FrameworkVersion = 'netstandard2.1'
            }
            Write-Verbose "Creating new project @$tempFolder"
            dotnet new classlib -o $tempFolder -n $ProjectTag -f $FrameworkVersion
            if(!$?)
            {
                throw "dotnet command failed"
            }
            Write-Host "Project file created. Version: $FrameworkVersion, Path: $projectfilePath"
        }
        class ImportNuget
        {
            [string]$Name
            [String]$Version
            [string]$Path
            new() {}
            [string]ToString()
            {
                return "$($this.name)/$($this.Version)"
            }
            Static [ImportNuget[]]Search([String]$Path)
            {
                return (gci $Path -File -Recurse -Filter ".nuget") | % {
                    $StorePath = join-path $_.Directory.FullName "nuget"
                    Import-Csv $_.FullName -Delimiter "/" -Header "name", "version"|%{
                        [importnuget]@{
                            Path = $StorePath
                            Name = $_.name
                            Version = $_.version
                        }
                    }
                }
            }
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'nugetfiles')
        {
            Write-Verbose "Searhing for .nuget files starting at path '$Path'"
            $NugetImport = [importnuget]::Search($Path)
        }
        #remove any overhead packages
        $ProjectFile = [xml](get-content $projectfilePath)
        $ProjectReferences = $ProjectFile.project.itemgroup.PackageReference
        $ProjectReferences|%{
            if($_.include -notin $NugetImport.name)
            {
                Write-Verbose "Removing Package"
                dotnet remove $projectfilePath package $_.include
            }
        }


        # $NugetImport
        foreach ($Import in $NugetImport)
        {
            if($Import.version -eq '*')
            {
                Write-Verbose "Adding $import to project"
                $Log = dotnet add $projectfilePath package $Import.Name|%{Write-debug $_;$_}
            }
            elseif($ProjectReferences|?{$_.include -eq $Import.name -and $_.version -eq $Import.version})
            {
                Write-Verbose "Package $import already added"
            }
            else {
                Write-Verbose "Adding $import to project"
                $Log = dotnet add $projectfilePath package $Import.Name --version $Import.Version|%{Write-debug $_;$_}
            }

            if(!$?)
            {
                throw "dotnet add command failed: $log"
            }
        }


        # $CurrPkg | % {
        # }

        Write-Verbose "Cleaning projectfolder "
        dotnet clean $projectfilePath

        # Write-Verbose "Restoring to download nuget to cache"
        dotnet restore $projectfilePath

        # #build project to collect dll's and generate at deps.json file
        Write-Verbose "Building to generate dll's to folder"
        dotnet build $projectfilePath --force -o 'C:\git\with.storage\test'

        # $DepsFile = gci $tempFolder -Filter "$tag.deps.json" -Recurse | select -First 1

        # if (!$DepsFile)
        # {
        #     throw "Could not find dependency file from project build. cannot continue"
        # }
        # $DllSource = $DepsFile.Directory
        # $DepsJson = get-content $DepsFile.FullName -Raw | convertfrom-json -AsHashtable
        # $RuntimeTarget = $DepsJson.runtimeTarget.name
        # $DepsTargets = $DepsJson.targets.$RuntimeTarget

        # # $DepsTargets
        # foreach ($ModuleInfo in $moduleFiles)
        # {

        #     $LoadDefinition = @()
        #     #if module has defined packages
        #     if ($ModuleInfo.data.packages)
        #     {
        #         #foreach defined package in modulefile
        #         Foreach ($Package in $ModuleInfo.data.packages)
        #         {
        #             Write-Host "Getting package '$($package.Name)/$($package.Version)' dependencies"
        #             $id = "$($package.Name)/$($package.Version)"
        #             $LoadDefinition = Get-DotnetDepsDependencies -TargetsObject $DepsTargets -PackageId $id -Order 1
        #             $LoadDefinition += "$id;0"
        #             # New-item -Path $ModuleInfo.
        #         }
        #     }


        #     $LoadDefinition = $LoadDefinition | Sort-Object order -Descending | select -Unique

        #     foreach ($Def in $LoadDefinition | ConvertFrom-Csv -Delimiter ";" -Header 'id', 'lo')
        #     {
        #         #packagename/version -> "packagename","version"
        #         $PackageName = $def.id.split("/")[0]
        #         $packagefile = gci $DllSource.FullName -Filter "$PackageName.dll" | select -First 1
        #         if (!$packagefile)
        #         {
        #             if ($def.lo -eq 0)
        #             {
        #                 throw "Could not find '$packagename.dll' in '$($DllSource.FullName)'"
        #             }
        #             else
        #             {
                        
        #                 Write-verbose "Ignoring '$packagename.dll'. could not find it, becuase 'dotnet build' didn't find it important, so why should i?"
        #             }
        #         }
        #     }
        # }
    }

    end
    {
    
    }
}


function Get-DotnetDepsDependencies
{
    [CmdletBinding()]
    [outputtype([array])]
    param (
        [hashtable]$TargetsObject,
        [string]$PackageId,
        [int]$Order
    )
    
    begin
    {
        $Target = $TargetsObject.$PackageId
    }
    
    process
    {
        if ($Target.dependencies)
        {
            $Target.dependencies.GetEnumerator().foreach{
                $id = $_.name + "/" + $_.value
                Get-DotnetDepsDependencies -TargetsObject $TargetsObject -PackageId $id -Order ($order + 1)
                Write-Output "$id;$order"
            }
        }
    }
    
    end
    {
        
    }
}



# $Interop.AssemblyQualifiedName

# .Invoke()

# Import-DotnetPackages -Path 'C:\git\with.storage' -FrameworkVersion netstandard2.1 -FromDotNuget -Verbose  #-Debug # -Searchbase 'C:\git\with.storage' -Verbose