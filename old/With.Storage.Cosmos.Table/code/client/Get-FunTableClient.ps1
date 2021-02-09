function Get-funTableClient {
    [CmdletBinding()]
    param (
        [String]$Connectionstring
    )
    
    begin {
        
    }
    
    process {
        $cs = [Microsoft.Azure.Cosmos.Table.CloudStorageAccount]::Parse($Connectionstring)
        [Microsoft.Azure.Cosmos.Table.CloudTableClient]$TableClient = [Microsoft.Azure.Cosmos.Table.CloudTableClient]::new($cs.TableEndpoint,$cs.Credentials)
        return $TableClient
    }
    
    end {
        
    }
}