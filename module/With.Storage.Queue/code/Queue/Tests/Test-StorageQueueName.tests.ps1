describe "Test-StorageQueueName" -tag 'cmdlet','queue'{
    InModuleScope "With.Storage.Queue"{
        <#
            * A queue name must start with a letter or number, and can only contain letters, numbers, and the dash (-) character.
            * The first and last letters in the queue name must be alphanumeric. The dash (-) character cannot be the first or last character. Consecutive dash characters are not permitted in the queue name.
            * All letters in a queue name must be lowercase.
            * A queue name must be from 3 through 63 characters long.
        #>
        $tests = @(
            @{
                type = "fail"
                desc = "start with non alphanumeric character"
                name = "-test"
            }
            @{
                type = "fail"
                desc = "ends with non alphanumeric character"
                name = "test-"
            }
            @{
                type = "fail"
                desc = "double dash"
                name = "tes--t"
            }
            @{
                type = "fail"
                desc = "uppercase"
                name = "Test"
            }
            @{
                type = "fail"
                desc = "non alphanumeric or dash character"
                name = "te#st"
            }
            @{
                type = "fail"
                desc = "less than 3 characters"
                name = "te"
            }
            @{
                type = "fail"
                desc = "more than 63 characters"
                name = ("k"*64)
            }
            @{
                type = "allow"
                desc = "name-number"
                name = "pester-1"
            }
            @{
                type = "allow"
                desc = "number-name"
                name = "pester-1"
            }
            @{
                type = "allow"
                desc = "name"
                name = "pester"
            }
            @{
                type = "allow"
                desc = "3 characters or more"
                name = "123"
            }
            @{
                type = "allow"
                desc = "63 charaters or less"
                name = ("k"*63)
            }
            @{
                type = "fail"
                desc = "63 charaters or less"
                name = ("k"*64)
            }
        )
    
        it "should <type> if name has <desc>" -TestCases $tests -Test{
            param(
                [string]$type,
                [string]$desc,
                [string]$name
            )
            if($type -eq 'fail')
            {
                $Validate = @(Test-StorageQueueName -Name $name)
                $Validate.count |should -be 1 -Because "should only have one error: $($Validate -join ', ')"
            }
            else {
                (Test-StorageQueueName -Name $name).count |should -BeExactly 0
            }
        }
    }
}