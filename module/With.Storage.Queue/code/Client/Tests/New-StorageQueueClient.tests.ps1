describe "New-StorageQueueClient" -Tag 'cmdlet','queue'{
    it "Creates a new client"{
        New-StorageQueueClient -Connectionstring $env:PesterStorageConnectionString|should -BeOfType [Microsoft.Azure.Storage.Queue.CloudQueueClient]
    }
}