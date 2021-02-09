function New-funTable {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [Microsoft.Azure.Cosmos.Table.CloudTableClient]$TableClient,
        [string]$name
    )
    
    begin {
    }
    
    process {
        $table = [Microsoft.Azure.Cosmos.Table.CloudTable]$TableClient.GetTableReference($Name)
        $table.CreateIfNotExists()
        return $Table
    }
    
    end {
        
    }
}