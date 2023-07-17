<# https://devblogs.microsoft.com/scripting/table-of-basic-powershell-commands/ #>

<#
 #########################
 #####--------------######
 #####----_MAIN_----######
 #####--_FUNCTION_--######
 #####--------------######
 #########################
#>
try 
{
     <# Clears the terminal at startup #>
     Clear-Host

     $Uris = Get-Content -Path .\uris.txt -Raw
     $WindowsUri = Get-GitWindowsUri $Uris
     Write-Host $WindowsUri
}
catch 
{
     Write-Error $_
}


<#
 #########################
 ####-----------------####
 ####----_HELPER_-----####
 ####---_FUNCTIONS_---####
 ####-----------------####
 #########################
#>

<#
.SYNOPSIS
     Returns windows uri for git latest release page on github website.
.EXAMPLE
     # Declared data
     $Uris = "WINWDOWS=www.example.com"

     # Function call
     Get-GitWindowsUri $Uris

     # Returned value
     www.example.com
#>
function Get-GitWindowsUri {
     param 
     (
          $Uris
     )

     try 
     {
          $UrisHastable = Convert-StringDataIntoHastable $Uris
          return $UrisHastable["WINDOWS"]
     }
     catch 
     {
          throw $_
     }

}

<#
.SYNOPSIS
     Parses string data into hashtable (key=value).
.LINK
     https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables
.EXAMPLE
     # Declared data
     $String = "TEST=This is example"

     # Function call
     Get-ValuesOfString $String

     # Returned value (hashtable)
     Name=TEST, Value=This is example
#>
function Convert-StringDataIntoHastable {
     param 
     (
          $Stringdata
     )
     try 
     {
          return ConvertFrom-StringData $Stringdata
     }
     catch 
     {
          throw $_
     }
}