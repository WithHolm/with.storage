# $InformationPreference = "Continue"
# # $ExportFunctions = @()
# if($PSScriptRoot)
# Get-ChildItem $PSScriptRoot -Recurse -Filter "*.ps1"|Where-Object{$($_.Directory.Name) -eq "Public" -or $($_.Directory.Name) -eq "Private"}|ForEach-Object{
#     # Write-Information "Importing $_"
#     . $_.FullName
# }

# if($global:pesteractive -eq $true)
# {
#     Get-ChildItem $PSScriptRoot -Recurse -Filter "*.ps1"|Where-Object{$($_.Directory.Name) -eq "pester"}|ForEach-Object{
#         # Write-Information "Importing $_"
#         . $_.FullName
#     }
# }

# $global:fun = @{
#     Async = $false
# }
# # if($global)