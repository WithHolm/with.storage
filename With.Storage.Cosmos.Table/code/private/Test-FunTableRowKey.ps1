function Test-funTableKey {
    [CmdletBinding()]
    [outputtype([string[]])]
    param (
        [String]$Key
    )
    
    begin {
        #https://docs.microsoft.com/en-us/rest/api/storageservices/Understanding-the-Table-Service-Data-Model
        $Result = @()
    }
    
    process {
        if([String]::IsNullOrEmpty($key))
        {
            $Result += "Key is empty"
        }
        #test if keylength is greater than 1kb or 1024
        if($Key.Length -gt 1204)
        {
            $Result += "Greater than 1024 characters"
        }

        (@{
            forwardslash = "/"
            backslash = "\\"
            numberSign = "#"
            questionMark = "?"
            tabLFCR = "\u0000-\u001F"
            controlCharacters = (127..159|%{('\u00'+('{0:x}' -f $_).ToUpper())}) -join ""
        }).GetEnumerator().foreach{
            # Write-host "[$($_.value)]"
            if($key -match "[$($_.value)]")
            {
                $Result += "key cannot contain $($_.name)"
            }
        }
        return $Result
    }
    
    end {
        
    }
}

# Test-funTableKey -key "tets?"