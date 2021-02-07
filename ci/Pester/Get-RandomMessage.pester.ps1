function get-randomMessage 
{
    return (gc "$PSScriptRoot\sc.json" -raw|convertfrom-json|get-random)
}