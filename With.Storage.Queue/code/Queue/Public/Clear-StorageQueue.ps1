
function Clear-StorageQueue {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [parameter(
            ValueFromPipeline,
            ParameterSetName = "Queue"
        )]
        [Microsoft.Azure.Storage.Queue.CloudQueue]$Queue,

        [parameter(
            ParameterSetName = "Name"
        )]
        [String]$Name,
        
        [parameter(
            ParameterSetName = "Name"
        )]
        [Microsoft.Azure.Storage.Queue.CloudQueueClient]$client,

        [switch]$Async
    )
    
    begin {
        if(![String]::IsNullOrEmpty($name))
        {
            $Queue = Get-StorageQueue -Client $client -Name $Name
        }
    }
    
    process {
        if ($pscmdlet.ShouldProcess($Queue.Name, "Clear")) {
            if($Async)
            {
                [void]$Queue.ClearAsync()
            }
            else {
                $Queue.Clear()
            }
        }
    }
    
    end {
        
    }
}