function ConvertTo-funTableEntity {
    [CmdletBinding()]
    [outputtype([Microsoft.Azure.Cosmos.Table.DynamicTableEntity])]
    param (
        [parameter(
            ValueFromPipeline,
            Mandatory,
            HelpMessage = "Items you want to process."
        )]
        $InputItem,
        [string[]]$select
    )
    
    begin {
    }
    
    process {
        "rowkey","partitionkey"|%{
            $tests = Test-funTableKey -Key $InputItem.$_
            if($tests.count -gt 0)
            {
                throw "$_ '$($InputItem.$_)' value error: $($tests -join ", ")"
            }        
        }

        $properties = @()
        if($InputItem -is [hashtable])
        {
            # Adding the additional columns to the table entity
            $properties = $InputItem.Keys
        }
        else
        {
            if($InputItem -ne [pscustomobject])
            {
                Set-FunWarning -tag 'WarnConvertType' -message "The inputitem is of type $($InputItem.gettype()), and i cannot guarantee full support. it might work, but please check output."
            }
            $properties = $InputItem.psobject.properties.name
        }

        $ignore = @("rowkey","partitionkey","TableTimestamp")
        $entity = [Microsoft.Azure.Cosmos.Table.DynamicTableEntity]::new($InputItem.partitionkey,$InputItem.rowkey)
        foreach($prop in $properties)
        {
            if($prop -in $ignore)
            {
                #skip item, go to next
                continue
            }
            if($select.count -gt 0 -and $prop -notin $select)
            {
                #skip item, go to next
                continue
            }
            $entity.Properties.Add($prop, $InputItem.$prop)
        }
        Write-Output $entity
    }
    
    end {
        
    }
}

# @{test=1;partitionkey=1;rowkey="r"}|ConvertTo-funTableEntity -Verbose