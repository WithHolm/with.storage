param(
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo]$module = "C:\git\with.storage\With.Storage.Base\With.Storage.Base.psm1"
)

Describe $module.basename -Tag "module" {

    $testcases = $((get-module $module.BaseName).exportedcommands.Keys|?{
        gci $module.Directory.FullName -Recurse -Filter "$_*" -Exclude "*pesterhelp*"
    }|Sort-Object|%{@{name=$_}})

    It "<name> should have a pester test" -TestCases $testcases {
        param(
            $name
        )
        gci $PSScriptRoot -Filter "$name.tests.ps1" -Recurse|should -HaveCount 1
    }
}