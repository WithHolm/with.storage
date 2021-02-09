function New-MongoDbClient {
    [CmdletBinding()]
    param (
        [String]$ConnectionString
    )
    
    begin {
        if($ConnectionString)
        {
            Write-Verbose "MongoDB Connection"
            
            $ConnectionString -match "mongodb:\/\/(?'usr'.*):.*@(?'uri'.*):(?'port'\d+)"|Out-Null
            Write-Verbose "User: '$($matches['usr'])', Uri: '$($matches['uri'])', Port: '$($matches['port'])'"
        }
    }
    
    process {
        
    }
    
    end {
        
    }
}

New-MongoDbClient -ConnectionString 'mongodb://localhost:C2y6yDjf5%2FR%2Bob0N8A7Cgv30VRDJIWEHLM%2B4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw%2FJw%3D%3D@localhost:10255/admin?ssl=true' -Verbose