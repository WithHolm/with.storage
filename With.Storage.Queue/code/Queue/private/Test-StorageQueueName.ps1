function Test-StorageQueueName {
    [CmdletBinding()]
    [outputtype([array])]
    param (
        [String]$Name
    )
    process {
        <#
            * A queue name must start with a letter or number, and can only contain letters, numbers, and the dash (-) character.
            * The first and last letters in the queue name must be alphanumeric. The dash (-) character cannot be the first or last character. Consecutive dash characters are not permitted in the queue name.
            * All letters in a queue name must be lowercase.
            * A queue name must be from 3 through 63 characters long.
        #>
        $validatetests = @(
            @{
                test = ($name -notmatch "^[a-z0-9]")
                response = "have to start with a-z or 0-9"
            }
            @{
                test = ($name -notmatch "[a-z0-9]$")
                response = "have to end with a-z or 0-9"
            }
            @{
                test = ($name -notmatch "^[a-z0-9-]{1,}$")
                response = "can only use a-z, 0-9 and -. All lowercase"
            }
            @{
                test = ($name -cne $name.ToLower())
                response = "cannot use upper case letters"
            }
            @{
                test = ($name -match "[-]{2,}")
                response = "Can not use sequentially dashes"
            }
            @{
                test = ($name.Length -lt 3)
                response = "have to be min 3 characters"
            }
            @{
                test = ($name.Length -gt 63)
                response = "have to be max 63 characters"
            }
        )
        foreach($test in $validatetests)
        {
            if($test.test)
            {
                $test.response
            }
        }
    }
}