# https://devblogs.microsoft.com/scripting/table-of-basic-powershell-commands/
# https://www.youtube.com/watch?v=X6nU5QCF8XI&list=PLnK11SQMNnE5_cl8n54h6OXNMnGl5Odtq

<#
 #########################
 #####--------------######
 #####---_DEFINE_---######
 #####----_ARGS_----######
 #####--------------######
 #########################
#>

param (
     [Alias('s')]
     [switch]$slow,

     [Alias('y')]
     [switch]$yes,

     [Alias('g')]
     [switch]$gui,

     [Parameter(Mandatory = $true)]
     [Alias('n')]
     [string]$gitname,

     [Parameter(Mandatory = $true)]
     [Alias('e')]
     [mailaddress]$gitemail
)

# Import helper functions
Import-Module .\src\windows\Get-FileFromWeb.ps1

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
    Retrieves the HTML element whose 'href' attribute matches a specified regex pattern from HTML content.
#>
function Get-ElementByHrefRegexPattern($HtmlContent, $HrefRegex) {
     try {
          $filteredUris = $HtmlContent.Links | Where-Object { $_.href -like $HrefRegex }

          if ($filteredUris) {
               return $filteredUris | Select-Object -First 1
          }
          else {
               throw "Element with matching URI '$HrefRegex' was not found in the HTML content."
          }
     }
     catch {
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
     param (
          [string]$Stringdata
     )

     try {
          return ConvertFrom-StringData $Stringdata
     }
     catch {
          throw $_
     }
}

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
     # TODO: Refactor code

     # Clears the terminal at startup
     Clear-Host

     # Read and parse constants into a hashtable
     $rawConstants = Get-Content -Path '.\src\constants.txt' -Raw
     $constantsTable = Convert-StringDataIntoHastable $rawConstants

     # Get constant values for the process
     $gitReleaseUri = $constantsTable['WINDOWS_RELEASE_GITHUB_URI']
     $gitDownloadUri = $constantsTable['WINDOWS_RELEASE_GITHUB_DOWNLOAD_URI']
     $gitReleaseRegex = $constantsTable['LATEST_GITHUB_URI_REGEX']

     # Fetch HTML content of the Git release page from GitHub
     $gitReleaseHtmlContent = Invoke-WebRequest -Uri $gitReleaseUri -UseBasicParsing

     # Extract the elem for the latest version of the Git release on Windows
     $gitReleaseHtmlElem = Get-ElementByHrefRegexPattern -HtmlContent $gitReleaseHtmlContent -HrefRegex "*$($gitReleaseRegex)*" # * - This matches any number of any characters before and after the pattern

     # Extract, sanitize and parse uri of the elem
     $latestGitReleaseUri = [System.Uri]::UnescapeDataString($gitReleaseHtmlElem.href -split [regex]::Escape($gitReleaseRegex))

     # Extract latest version naming of Git from URI
     $latestGitVersionNaming = ($latestGitReleaseUri -split '/' | Select-Object -Last 1)

     # Extract latest version of Git
     # TODO: Move regex patterns into constants file
     if ($latestGitVersionNaming -match 'v(.*?)\.windows') {
          $latestGitVersion = $matches[1]
     }
     else {
          throw "Couldn't extract Git version."
     }

     # Create uri for downloading latest windows version
     # TODO: Move link patterns into constants file
     $latestGitDownloadUri = $gitDownloadUri + $latestGitVersionNaming + '/Git-' + $latestGitVersion + '-64-bit.exe'

     # Download installer for Git
     # TODO: Move file name into constants file
     Invoke-WebRequest -Uri $latestGitDownloadUri -OutFile 'git-latest.exe'

     # Install Git
     # TODO: Implement silent installation through cmd here

     # Delete the installer after the installation process is complete
     # TODO: Move file name into constants file
     Remove-Item -Path '.\git-latest.exe'

     Write-Host $latestGitDownloadUri
}
catch 
{
     Write-Error $_
}
