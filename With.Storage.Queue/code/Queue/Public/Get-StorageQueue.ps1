function Get-StorageQueue {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Azure.Storage.Queue.CloudQueueClient]$Client,

        [parameter(
            HelpMessage="Name of storagequeue."
        )]
        [String]$Name,
        [Switch]$ThrowIfNotFound
    )
    
    begin {
        
    }
    
    process {
        if(![String]::IsNullOrEmpty($Name))
        {
            $return = $Client.ListQueues($Name)
        }
        else {
            $return = $Client.ListQueues()
        }

        if([String]::IsNullOrEmpty($return) -and $ThrowIfNotFound)
        {
            throw "Could not find queue '$name' with account '$($client.BaseUri)'"
        }
        else 
        {
            return $return
        }
        

    }
    
    end {
        
    }
}