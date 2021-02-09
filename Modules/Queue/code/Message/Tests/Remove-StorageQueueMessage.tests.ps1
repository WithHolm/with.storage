Describe "Remove-StorageQueueMessage" -Tag 'cmdlet','queue'{
    BeforeEach{
        $Client = New-StorageQueueClient -Connectionstring $env:PesterStorageConnectionString
        $Queue = New-StorageQueue -Client $Client -Name "pester"
        $Queue.Clear()
    }

    it "removes a specific message" {
        New-StorageQueueMessage -Data "pester" -Queue $Queue
        $msg = Get-StorageQueueMessage -Queue $Queue -VisibilityTimeout "0:0:0.1"
        $msg|should -HaveCount 1
        Remove-StorageQueueMessage -Queue $Queue -message $msg
        Start-Sleep -Milliseconds 100
        $msg = Get-StorageQueueMessage -Queue $Queue -VisibilityTimeout "0:0:0.1"
        $msg|should -HaveCount 0
    }
    it "accepts pipeline" {
        New-StorageQueueMessage -Data "pester" -Queue $Queue
        $msg = Get-StorageQueueMessage -Queue $Queue -VisibilityTimeout "0:0:0.1"
        $msg|should -HaveCount 1
        $msg|Remove-StorageQueueMessage -Queue $Queue
        Start-Sleep -Milliseconds 100
        $msg = Get-StorageQueueMessage -Queue $Queue -VisibilityTimeout "0:0:0.1"
        $msg|should -HaveCount 0
    }
    it "throws on messages that are peeked" {
        New-StorageQueueMessage -Data "pester" -Queue $Queue
        $msg = Get-StorageQueueMessage -Queue $Queue -Peek
        $msg|should -HaveCount 1
        {$msg|Remove-StorageQueueMessage -Queue $Queue}|should -Throw
        # Start-Sleep -Milliseconds 100
        # $msg = Get-StorageQueueMessage -Queue $Queue -VisibilityTimeout "0:0:0.1"
        # $msg|should -HaveCount 0
    }
}