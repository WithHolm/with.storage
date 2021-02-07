function Get-Framework
{
    [CmdletBinding()]
    param (
        [Switch]$IncludeVersion
    )
    
    begin
    {
        
    }
    
    process
    {
        #try basic first. on older dotnet versions this returns null
        $FWVersion = [System.Runtime.InteropServices.RuntimeInformation]::FrameworkDescription
        # $Interop = ([System.AppDomain]::CurrentDomain.GetAssemblies().where{
        #     $_.FullName -like 'System.Runtime.InteropServices.RuntimeInformation,*'
        # }).ExportedTypes.where{$_.name -like "runtime*"}

        if (!$FWVersion)
        {
            #ususally done by dotnet standard
            $Interop = ([System.AppDomain]::CurrentDomain.GetAssemblies().where{
                    $_.FullName -like 'mscorlib*'
                }).exportedtypes.where{ $_.fullname -like "*runtimeinformation*" }
            $FWVersion = [scriptblock]::Create("[$($Interop.AssemblyQualifiedName)]::FrameworkDescription").Invoke()
        }

        # $FWVersion
        $regex = "(?'Framework'[.]NET( Core| Framework| Native|)) (?'Version'.*)"
        if([regex]::IsMatch($FWVersion,$regex))
        {
            $regout = [regex]::Matches($FWVersion,$regex)
            
            # $Matches
            if($IncludeVersion)
            {
                $FWVersion
            }
            else {
                ($regout.groups.where{$_.name -eq 'Framework'}).value
                # $Matches['Framework']
            }
        }
    }
    
    end
    {
        
    }
}
Get-Framework