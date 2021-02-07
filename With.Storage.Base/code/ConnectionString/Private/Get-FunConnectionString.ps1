<#
.SYNOPSIS
Returns connectionstring defined in env

.DESCRIPTION
Returns connectionstring defined in env.
if $env:fun_cs has a key defined, return this key, else check if 'AzureWebJobsStorage' env is filled and use this.

.EXAMPLE
$env:connection = "some connection string"
$env:fun_cs = "connection"
Get-FunConnectionString
#returns "some connection string"

.EXAMPLE
$env:AzureWebJobsStorage = "some connection string"
Get-FunConnectionString
#returns "some connection string"

.EXAMPLE
$env:AzureWebJobsStorage = "some connection string"
$env:connection = "other connection string"
$env:fun_cs = "connection"
Get-FunConnectionString
#returns "other connection string"

.NOTES
General notes
#>
function Get-FunConnectionString {
    [CmdletBinding()]
    param ()
    
    begin {
        
    }
    
    process {
        if(![string]::IsNullOrEmpty($env:fun_cs))
        {
            return ("`$env:$($env:fun_cs)"|Invoke-Expression)
        }
        else {
            if(-not [string]::IsNullOrEmpty($env:AzureWebJobsStorage))
            {
                return ($env:AzureWebJobsStorage)
            }
        }
    }
    
    end {
        
    }
}