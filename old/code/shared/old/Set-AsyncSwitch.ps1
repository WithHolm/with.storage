function Set-AsyncSwitch {
    [CmdletBinding()]
    param (
        [bool]$Enable
    )
    
    begin {
        
    }
    
    process {
        if($Enable)
        {
            Write-verbose "Enabling async for fun.storage"
        }
        else {
            Write-verbose "Disabling async for fun.storage"
        }
        Write-Verbose "Setting async to '$enable'"
        $global:fun.Async = $Enable
    }
    
    end {
        
    }
}