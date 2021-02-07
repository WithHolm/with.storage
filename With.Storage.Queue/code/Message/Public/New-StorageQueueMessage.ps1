using namespace Microsoft.Azure.Storage
function New-StorageQueueMessage {
    [CmdletBinding()]
    # [outputtype]
    param (
        
        [parameter(
            Mandatory,
            HelpMessage="Data to have in message"
        )]
        [object[]]$Data,

        [parameter(
            HelpMessage="will convert input to base64 string before sending it to Queue. Required by Function Queue triggers."
        )]
        [switch]$AsBase64,

        [parameter(
            Mandatory,
            HelpMessage='{Queue}'
        )]
        [Microsoft.Azure.Storage.Queue.CloudQueue]$Queue,

        [parameter(
            HelpMessage='
            {Timespan.types}
            How long do you want the message to be present in the queue?
            {Timespan.protocoll}
            '
        )]
        [timespan]$TimeToLive = [timespan]::FromDays(7),

        [parameter(
            HelpMessage='
            {Timespan.types}
            interval of time from now during which the message will be invisible in queue
            {Timespan.protocoll}
            '
        )]
        [timespan]$InitialVisibilityDelay = [timespan]::Zero,

        [switch]$Async,

        [int]$AsyncMaxWait = 10000
    )
    
    begin {
        $messageString = $($data -join '')

        #if string is sent in as base64, check if its encoding
        if($AsBase64)
        {
            Write-Debug "converting data to base64"
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($messageString)
            $messageString = [convert]::ToBase64String($bytes)
            $Queue.EncodeMessage = $true
        }
    }
    process {
        $Message = [Microsoft.Azure.storage.queue.CloudQueueMessage]::new($messageString,$AsBase64.IsPresent)
        Write-Verbose "Message is: $($message|ConvertTo-Json)"

        $AsyncPut = $Queue.AddMessageAsync($Message,$TimeToLive,$InitialVisibilityDelay,$null,$null)
        if(!$Async)
        {
            [void]($AsyncPut.Wait([timespan]::FromMilliseconds(200)))
            $timer = get-date
            while($AsyncPut.IsCompleted -eq $false)
            {
                Write-debug "Waiting for task to complete"
                [void]($AsyncPut.Wait([timespan]::FromMilliseconds(200)))
                if((get-date).AddMilliseconds(([math]::Abs($AsyncMaxWait)*-1)) -gt $timer)
                {
                    throw "Waited over $([timespan]::FromMilliseconds([math]::Abs($AsyncMaxWait)).TotalSeconds) seconds for message to send."
                }
            }
        }
        else {
            return $AsyncPut
        }
    }
    end {}
}
