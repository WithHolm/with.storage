function Get-Randomstring{
    return [System.IO.Path]::GetRandomFileName().Replace(".","-")
}