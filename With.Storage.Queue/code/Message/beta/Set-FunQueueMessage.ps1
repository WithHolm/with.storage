function Set-funQueueMessage {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory
        )]
        [Microsoft.Azure.Storage.Queue.CloudQueue]$queue,

        [parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [Microsoft.Azure.Storage.Queue.CloudQueueMessage]$message,
        [object[]]$Data,
        
        [parameter(HelpMessage="should data be Base64 encoded?")]
        [Switch]$Encode,

        [parameter(
            ParameterSetName="Get",
            HelpMessage="
            [String] or [Timespan].
            How long will you lease the message for?
            String should follow protocoll: '-1' = infinity, '1' = 1 day, '1:0' = 1 hour, '0:1' = 1 minute, '0:0:1' = 1 second"
        )]
        [timespan]$VisibilityTimeout = ""
    )
    
    begin {
        
    }
    
    process {
        if($Data)
        {
            $message.SetMessageContent2($($data -join ''),$Encode.IsPresent)
        }

        if([string]::IsNullOrEmpty($VisibilityTimeout))
        {

        }
    }
    
    end {
        
    }
}