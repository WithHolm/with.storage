function Remove-StorageQueueMessage {
    [CmdletBinding()]
    param (
        [parameter(
            HelpMessage='${Queue}',
            Mandatory
        )]
        [Microsoft.Azure.Storage.Queue.CloudQueue]$Queue,

        [parameter(
            Mandatory,
            ValueFromPipeline,
            HelpMessage = "Message to remove"
        )]
        [Microsoft.Azure.Storage.Queue.CloudQueueMessage]$message
    )
    
    begin {
        # if($message.PopReceipt)
        # {
        #     throw "Message needs a PopReceipt. cannot be a peeked message"
        # }
    }
    
    process {
        $queue.DeleteMessage($message)
    }
    
    end {
        
    }
}