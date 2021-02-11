Describe "Connect-StorageQueue" -Tag 'cmdlet','queue' {
    BeforeEach{
        $client = New-StorageQueueClient -Connectionstring $env:PesterStorageConnectionString
        $queue = New-StorageQueue -Client $client -Name "pester"
    }
    it "can connect to already existing storage queue"{
        {Connect-StorageQueue -Connectionstring $env:PesterStorageConnectionString -Name $queue.Name}|should -Not -Throw
    }

    it "can create new storage queue"{
        $str = $(Get-Randomstring)
        {Connect-StorageQueue -Connectionstring $env:PesterStorageConnectionString -Name $str -CreateIfNotExist}|should -Not -Throw
        Get-StorageQueue -Client $client -Name $str|should -HaveCount 1
    }

    it "can connect without storageconnectionstring if reference env is set"{
        $env:fun_cs = 'PesterStorageConnectionString'
        
    }
}