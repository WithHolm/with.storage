Describe "New-StorageQueueMessage" -Tag 'cmdlet','queue'{
    BeforeEach{
        $Client = New-StorageQueueClient -Connectionstring $env:PesterStorageConnectionString
        $Queue = New-StorageQueue -Client $Client -Name "pester"
        $Queue.Clear()
    }

    it "Can deliver a string message"{
        New-StorageQueueMessage -Data "pester" -Queue $Queue
        $msg = Get-StorageQueueMessage -Queue $Queue
        $msg|should -HaveCount 1
        $msg.AsString|should -be "pester"
    }

    it "-AsBase64 will accept BASE64 encoded message"{
        $String = "Pester"
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($String)
        $Base64String = [Convert]::ToBase64String($bytes)
        New-StorageQueueMessage -Data $Base64String  -AsBase64 -Queue $Queue
        $msg = Get-StorageQueueMessage -Queue $Queue
        $msg|should -HaveCount 1
        $msg.AsString|should -be $Base64String
    }

    it "-AsBase64 will convert string to BASE64"{
        $String = "Pester"
        $Queue.EncodeMessage = $false
        New-StorageQueueMessage -Data $String -AsBase64 -Queue $Queue
        $msg = Get-StorageQueueMessage -Queue $Queue
        $msg|should -HaveCount 1
        $msg.AsString|should -be "pester"
    }

    it "-InitialVisibilityDelay is honored"{
        New-StorageQueueMessage -Data "pester" -Queue $Queue -InitialVisibilityDelay "0:0:1"
        $msg = Get-StorageQueueMessage -Queue $Queue
        $msg|should -HaveCount 0
        Start-Sleep -Seconds 1
        $msg = Get-StorageQueueMessage -Queue $Queue
        $msg|should -HaveCount 1
        $msg.AsString|should -be "pester"
    }

    it "-TimeToLive is honored"{
        New-StorageQueueMessage -Data "pester" -Queue $Queue -TimeToLive "0:0:1"
        $msg = Get-StorageQueueMessage -Queue $Queue -Peek
        $msg|should -HaveCount 1
        $msg.AsString|should -be "pester"
        $msg.ExpirationTime|should -BeGreaterOrEqual ([System.DateTimeOffset]::UtcNow.AddSeconds(1).tostring()) -Because "TTL should be 1 second"
        Start-Sleep -Seconds 1
        $msg = Get-StorageQueueMessage -Queue $Queue
        $msg|should -HaveCount 0 -Because "should be gone after 1 second"
    }
}