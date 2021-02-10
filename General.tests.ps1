Describe "Module general tests" -Tag "module" {
    gci $PSScriptRoot -Directory|%{
        Write-host $_.FullName
    }

    # $testcases = $((get-module $module.BaseName).exportedcommands.Keys|?{
    #     gci $module.Directory.FullName -Recurse -Filter "$_*" -Exclude "*pesterhelp*"
    # }|Sort-Object|%{@{name=$_}})

    # It "<name> should have a pester test" -TestCases $testcases {
    #     param(
    #         $name
    #     )
    #     gci $PSScriptRoot -Filter "$name.tests.ps1" -Recurse|should -HaveCount 1
    # }
}