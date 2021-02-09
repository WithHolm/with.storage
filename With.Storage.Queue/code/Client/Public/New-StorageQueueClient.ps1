using namespace Microsoft.Azure.Storage
# using module az.resources
# using module az.storage

<#
.SYNOPSIS
Creates a new client for the azure storage queue

.DESCRIPTION
Creates a new client for the azure storage queue. 
Used to connect to queues.

.PARAMETER Connectionstring
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function New-StorageQueueClient {
    [CmdletBinding(DefaultParameterSetName = "Connectionstring")]
    [outputtype([Microsoft.Azure.Storage.Queue.CloudQueueClient])]
    param (
        [parameter(ParameterSetName = "Connectionstring" ,HelpMessage="Storage account connection string. 
            if you have a environment variable that stores this key, you can define the variable name by setting 'fun_cs' in environment or app config.")]
        [String]$Connectionstring = (Get-FunConnectionString),
        # [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResource]
    )
    
    begin {
        if([string]::IsNullOrEmpty($Connectionstring))
        {
            Write-verbose "`$env:fun_cs set:$([string]::IsNullOrEmpty($env:fun_cs)), Value:'$env:fun_cs'"
            throw "Missing connectionstring"
        }
    }
    
    process {
        $CS = [Microsoft.Azure.Storage.cloudstorageaccount]::Parse($Connectionstring)
        $q = $([Queue.CloudQueueClient]::new($cs.QueueStorageUri,$CS.Credentials))
        if([string]::IsNullOrEmpty($q))
        {
            throw "failed to create queue client"
        }
        else {
            return $q
        }
    }
    
    end {
    }
}