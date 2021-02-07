function Get-funTable {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [Microsoft.Azure.Cosmos.Table.CloudTableClient]$TableClient,
        [string]$name,
        [switch]$throwOnNotFound
    )
    
    begin {
    }
    
    process {
        $table = [Microsoft.Azure.Cosmos.Table.CloudTable]$TableClient.GetTableReference($Name)
        if($throwOnNotFound)
        {
            throw "Could not find table '$name'"
        }
        return $Table
    }
    
    end {
        
    }
}