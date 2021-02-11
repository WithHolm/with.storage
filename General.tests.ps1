Describe "Module general tests" -Tag "module" {
    $moduleName = split-path $PSScriptRoot -Leaf

    $testcases = $((get-module $moduleName).exportedcommands.Keys|?{
        gci $module.Directory.FullName -Recurse -Filter "$_*" -Exclude "*pesterhelp*"
    }|Sort-Object|%{@{name=$_}})

    It "<name> should have a pester test" -TestCases $testcases {
        param(
            $name
        )
        gci $PSScriptRoot -Filter "$name.tests.ps1" -Recurse|should -HaveCount 1
    }
}