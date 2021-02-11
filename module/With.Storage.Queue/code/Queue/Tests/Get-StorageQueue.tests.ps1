Describe "Get-StorageQueue" -Tag 'cmdlet','queue'{
    
    BeforeEach{
        $queues = @("pester-one","pester-two","test-one","test-two","test-three","philip-one","philip-two","philip-three","philip-four","testing-1","hey-1","hey-2")
        $client = New-StorageQueueClient -Connectionstring $env:PesterStorageConnectionString
        $client.ListQueues()|%{$_.delete()}
        $queues|ForEach-Object{
            New-StorageQueue -Name $_ -Client $Client
        }
        $testcases = @($queues|%{$_.split("-")|Select-Object -First 1}|Select-Object -Unique|%{@{name = $_}})
    }

    It "lists avalible queues if avalible" -Test {
        @(Get-StorageQueue -Client $client)|should -HaveCount $queues.Count
    }

    it "lists avalible queues with prefix <name>" -TestCases $testcases -Test {
        param(
            [string]$Name
        )
        (Get-StorageQueue -Client $client -Name $Name)|should -HaveCount @($queues|?{$_ -like "$name*"}).Count
    }

}