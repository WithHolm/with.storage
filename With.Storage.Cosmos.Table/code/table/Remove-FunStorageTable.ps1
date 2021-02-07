function Remove-funTable {
    [CmdletBinding()]
    param (
        [Microsoft.Azure.Cosmos.Table.CloudTable]$Table,
        [switch]$Async
    )
    
    begin {
        
    }
    
    process {
        $request = [Microsoft.Azure.Cosmos.Table.TableRequestOptions]::new()
        $OperationContext = [Microsoft.Azure.Cosmos.Table.OperationContext]::new()
        if($Async)
        {
            $table.DeleteIfExistsAsync($request,$OperationContext)
        }
        else {
            $Table.DeleteIfExists($request,$OperationContext)
        }
    }
    
    end {
        
    }
}