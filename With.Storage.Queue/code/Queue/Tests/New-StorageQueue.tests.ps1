InModuleScope "fun.storage"{
    Describe "New-StorageQueue" -Tag 'cmdlet','queue'{
        BeforeEach{
            $client = New-StorageQueueClient -Connectionstring $env:PesterStorageConnectionString
        }
    
        it "Can create a new storage queue if defined"{
            {New-StorageQueue -Client $client -Name "pester1"}|should -Not -Throw
            $queue = Get-StorageQueue -Client $client -Name "pester1"
            $queue|should -not -BeNullOrEmpty
        }
    
        it "Name cannot be empty"{
            {New-StorageQueue -Client $client -Name ''}|should -Throw
        }
    
        it "Will test name"{
            mock -CommandName Test-StorageQueueName -MockWith {return @()}
            $k = New-StorageQueue -Client $client -Name 'kkk'
            Assert-MockCalled -CommandName Test-StorageQueueName
        }
    }
}