function Invoke-FunBatchProcess {
    [CmdletBinding()]
    param (
        [parameter(
            ValueFromPipeline,
            Mandatory,
            HelpMessage = "Items you want to process. Should be a array of pscustomobjects or hashtables"
        )]
        $InputItem,

        [parameter(
            Mandatory,
            HelpMessage = "Table to use"
        )]
        [Microsoft.Azure.Cosmos.Table.CloudTable]$Table,

        [String[]]$RowKey,
        
        [Switch]$HashRowKey,

        [String]$PartitionKey,

        [ValidateRange(1,100)]
        $BatchSize = 100,

        [switch]$Async
    )
    
    begin {
        $batches = @{}
        $Index = 0
    }
    
    process {
        [string]$RowKeyValue = ""
        #region validate rowkey and partitionkey
        #if rowkey is defined as a property in the object
        if([String]::IsNullOrEmpty($RowKey))
        {
            if([String]::IsNullOrEmpty($InputItem.rowkey))
            {
                Throw "no rowKey was defined at index $Index"
            }
            $RowKeyValue = $InputItem.rowkey
        }
        #if rowkey is referenced
        else{
            foreach($key in $RowKey)
            {
                if([String]::IsNullOrEmpty($InputItem.$key))
                {
                    Throw "missing data in rowKey definition '$key' at index $index"
                }
            }
            $RowKeyValue = $RowKey -join "_"
        }
        if($HashRowKey)
        {
            $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
            $utf8 = New-Object -TypeName System.Text.UTF8Encoding
            $RowKeyValue = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($RowKeyValue)))
        }
        $RowkeyTests = Test-funTableKey -Key $RowKeyValue
        if($RowkeyTests.Count -gt 0)
        {
            throw "rowkey value error: $($RowkeyTests -join ", ") at index $index"
        }

        if([String]::IsNullOrEmpty($PartitionKey))
        {
            if([String]::IsNullOrEmpty($InputItem.partitionkey))
            {
                Throw "no rowKey was defined at index $Index"
            }
            $PartitionKeyValue = $InputItem.partitionkey
        }
        else {
            elseif([String]::IsNullOrEmpty($InputItem.$PartitionKey))
            {
                Throw "missing data in partitionKey definition '$key' at index $index"
            }
            $PartitionKeyValue = $InputItem.$PartitionKey
        }
        $PartitionkeyTests = Test-funTableKey -Key $PartitionKeyValue
        if($PartitionkeyTests.Count -gt 0)
        {
            throw "rowkey value error: $($PartitionkeyTests -join ", ") at index $index"
        }
        #endregion

        

        $Count++
    }
    
    end {
        
    }
}