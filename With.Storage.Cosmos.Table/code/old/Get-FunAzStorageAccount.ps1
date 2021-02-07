function Get-FunAzStorageAccount {
    [CmdletBinding()]
    param (
        [String]$Name,
        [String]$ResourceGroup
    )
    
    begin {
        
    }
    
    process {
        $StorageAccounts = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts' -Name $Name|?{$_.ResourceGroupName}
    }
    
    end {
        
    }
}