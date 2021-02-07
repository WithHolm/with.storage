Describe "Get-StorageQueueMessage" -Tag 'cmdlet','queue'{
    BeforeAll{
        $Client = New-StorageQueueClient -Connectionstring $env:PesterStorageConnectionString
        $Queue = New-StorageQueue -Client $Client -Name "pester"
    }

    context "Normal"{
        BeforeEach{
            $Queue.Clear()
        }
        it "delivers Microsoft.Azure.Storage.Queue.CloudQueueMessage"{
            # [Microsoft.Azure.storage.queue.CloudQueueMessage]::new("test",$false)
            $msg = [Microsoft.Azure.storage.queue.CloudQueueMessage]::new("pester",$false)
            $Queue.AddMessage($msg)

            Get-StorageQueueMessage -Queue $Queue -count 1|should -BeOfType [Microsoft.Azure.Storage.Queue.CloudQueueMessage] 
        }

        $testcase = @(1,5,10,15,32)|%{@{count=$_}}
        it "Loads <count> messages when instructed" -TestCases $testcase {
            param(
                [int]$count
            )
            @(0..$count)|%{
                # Write-host "created message"
                $msg = [Microsoft.Azure.storage.queue.CloudQueueMessage]::new("pester$_",$false)
                $Queue.AddMessage($msg)
                # New-StorageQueueMessage -Data "pester$_" -Queue $Queue
            }
            Start-Sleep -Milliseconds 100
            $Messages = Get-StorageQueueMessage -Queue $Queue -count $count -VisibilityTimeout 1
            $Messages|should -HaveCount $count
            $Messages|%{
                $_.AsString|should -BeLike "pester*"
            }
            # $Queue.Clear()
        }
        
        it "Throws when loading <msg> <count> messages" -TestCases @(
            @{
                msg="more than"
                count = 32
                using = 33
            }
            @{
                msg="less than"
                count = 1
                using = 0
            }
        ) -Test {
            param(
                $msg,
                $count,
                $using
            )
            @(0..$count)|%{
                $msg = [Microsoft.Azure.storage.queue.CloudQueueMessage]::new("pester$_",$false)
                $Queue.AddMessage($msg)
            }
            {Get-StorageQueueMessage -Queue $Queue -count $using -VisibilityTimeout 1000}|should -Throw
        }
        
        # Clear-StorageQueue -Queue $Queue
        it "Visibilitytimeout is honored"{
            $msg = [Microsoft.Azure.storage.queue.CloudQueueMessage]::new("pester",$false)
            $Queue.AddMessage($msg)
            # New-StorageQueueMessage -Data "pester" -Queue $Queue
            Start-Sleep -Milliseconds 100
            $msg = Get-StorageQueueMessage -Queue $Queue -count 1
            Get-StorageQueueMessage -Queue $Queue -count 1|should -HaveCount 0
        }
    }
    
    context "Peek"{
        BeforeEach{
            $Queue.Clear()
            $msg = [Microsoft.Azure.storage.queue.CloudQueueMessage]::new("pester",$false)
            $Queue.AddMessage($msg)
            # New-StorageQueueMessage -Data "pester" -Queue $Queue
        }
        # $Queue.Clear()
        
        it "can peek message"{
            Get-StorageQueueMessage -Queue $Queue -count 1 -Peek|should -HaveCount 1
        }
        it "visibility not affected"{
            Get-StorageQueueMessage -Queue $Queue -count 1 -Peek|should -HaveCount 1
            Get-StorageQueueMessage -Queue $Queue -count 1 -Peek|should -HaveCount 1
        }
        it "delivers Microsoft.Azure.Storage.Queue.CloudQueueMessage"{
            Get-StorageQueueMessage -Queue $Queue -count 1 -Peek|should -BeOfType [Microsoft.Azure.Storage.Queue.CloudQueueMessage] 
        }
    }

}