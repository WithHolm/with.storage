using namespace Microsoft.Azure.Storage
Describe "Clear-StorageQueue" -Tag 'cmdlet','queue'{
    BeforeEach{
        $client = New-StorageQueueClient -Connectionstring $env:PesterStorageConnectionString -Verbose
        $queue = New-StorageQueue -Name (Get-Randomstring) -Client $Client
    }

    it "Can clear queue by pipeline" -test {
        New-StorageQueueMessage -Data (get-randomMessage) -Queue $queue

        $queue|Get-StorageQueueMessage -Peek|should -HaveCount 1
        $queue|Clear-StorageQueue
        $queue|Get-StorageQueueMessage -Peek|should -HaveCount 0
    }

    it "Can clear queue by parameters - queue" -test {
        New-StorageQueueMessage -Data (get-randomMessage) -Queue $queue

        $queue|Get-StorageQueueMessage -Peek|should -HaveCount 1
        Clear-StorageQueue -Queue $queue
        $queue|Get-StorageQueueMessage -Peek|should -HaveCount 0
    }

    it "Can clear queue by parameters - name + client" -test {
        New-StorageQueueMessage -Data (get-randomMessage) -Queue $queue

        $queue|Get-StorageQueueMessage -Peek|should -HaveCount 1
        Clear-StorageQueue -name $queue.Name -client $queue.ServiceClient
        $queue|Get-StorageQueueMessage -Peek|should -HaveCount 0
    }

    it "will fail when name is defined and client not defined"{
        {Clear-StorageQueue -name $queue.Name}|should -Throw
    }

    it "will fail when client is defined and no name is present"{
        {Clear-StorageQueue -client $queue.ServiceClient}|should -Throw
    }
}