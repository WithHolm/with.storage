using namespace Microsoft.Azure.Storage

function Connect-StorageQueue {
    [CmdletBinding()]
    [outputtype([Microsoft.Azure.Storage.Queue.CloudQueue])]
    
    param (
        [parameter(HelpMessage="
        Storage account connection string. 
        if you have a environment variable that stores this key, you can define the variable name by setting 'fun_cs' in environment or app config.
        ")]
        [String]$Connectionstring,

        [parameter(Mandatory,HelpMessage="Name of queue to use")]
        [String]$Name,
        [Switch]$CreateIfNotExist
    )
    
    begin {
        $Name = $Name.ToLower()
    }
    
    process {
        if([string]::IsNullOrEmpty($Connectionstring))
        {
            $client = New-StorageQueueClient
        }
        else {
            $client = New-StorageQueueClient -Connectionstring $Connectionstring
        }
        Write-Verbose "connected with client '$($client.BaseUri)'"


        $Queue = Get-funQueue -Client $client -Name $Name

        if($CreateIfNotExist -and [string]::IsNullOrEmpty($Queue))
        {
            $Queue = New-funQueue -Client $client -Name $Name
        }
        
        if(!$Queue)
        {
            throw "Cannot find queue named '$name'"
        }

        return $Queue
    }
    
    end {
        
    }
}