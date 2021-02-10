function Set-FunWarning {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$message,
        [ValidateNotNullOrEmpty()]
        [string]$tag,
        [switch]$Reset
    )
    
    begin {
        if(!$global:warningDict)
        {
            $global:warningDict = @()
        }
    }
    
    process {
        if($Reset)
        {
            if($tag -in $global:warningDict)
            {
                $global:warningDict.Remove($tag)
            }
        }
        else {
            if($tag -notin $global:warningDict)
            {
                $global:warningDict += $tag
                Write-Warning $message
            }
        }
    }
    
    end {
        
    }
}