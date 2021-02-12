Describe "$env:pester_module_name general tests" -Tag "module" {
    $module =  
    $testcases = $((get-module $env:pester_module_name).exportedcommands.Keys|?{
        gci $env:pester_module_fullname -Recurse -Filter "$_*" -Exclude "*pesterhelp*"
    }|Sort-Object|%{@{name=$_}})

    # Write-host $env:pester_module_name
    It "<name> should have a pester test" -TestCases $testcases {
        param(
            $name
        )
        gci $env:pester_module_fullname -Filter "$name.tests.ps1" -Recurse|should -HaveCount 1
    }
}