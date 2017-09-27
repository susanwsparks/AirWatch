<# Execute-AWRestAPI Powershell Script Help

  .SYNOPSIS
    This Poweshell script make a REST API call to an AirWatch server.  This particular script is used to update the devices AssetNumber matching the passed in Serial.

  .USAGE
    Edit the powershell and change the userName, password, and tenantAPIKey to match
    the information given to you by AirWatch. As needed update your endpointURL as well.

  .PARAMETER id)
    This is the location identifier

  .PARAMETER outputFile (optional)
    This is not required.  If you don't specify this parameter on the command line, the script will just show

  .PARAMETER configFile (optional)
    This is not required.  If you don't specify this parameter on the command line, the script will just show

#>

[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$id,

        [Parameter()]
        [string]$outputFile,

        [Parameter()]
        [string]$configFile
)

. ".\Expand-Nested.ps1"

If (!$PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
    $ErrorActionPreference = "SilentlyContinue"
}

If (!$configFile) {
    $configFile = ".\awupdaterrc.ps1"
}
. $configFile

Function Get-BasicUserForAuth {

	Param([string]$func_username)

	$userNameWithPassword = $func_username
	$encoding = [System.Text.Encoding]::ASCII.GetBytes($userNameWithPassword)
	$encodedString = [Convert]::ToBase64String($encoding)

	Return "Basic " + $encodedString
}

Function Build-Headers {
    Param([string]$authoriztionString, [string]$tenantCode, [string]$acceptType, [string]$contentType)

    $authString = $authoriztionString
    $tcode = $tenantCode
    $accept = $acceptType
    $content = $contentType

    Write-Verbose("---------- Headers ----------")
    Write-Verbose("Authorization: " + $authString)
    Write-Verbose("aw-tenant-code: " + $tcode)
    Write-Verbose("Accept: " + $accept)
    Write-Verbose("Content-Type: " + $content)
    Write-Verbose("------------------------------")
    Write-Verbose("")
    $header = @{"Authorization" = $authString; "aw-tenant-code" = $tcode; "Content-Type" = $useJSON}
     
    Return $header
}

<#
  This is a function based on https://www.uvm.edu/~gcd/2010/11/powershell-join-string-function/.  What it does is take an array of all
  of the device fields and create a comma separated line of data for output.
#>
Function Get-StringFromArray {

    Param([Array]$deviceFields, [string]$separator = ",")

    $first = $True
    Write-Output ("Device Fields: " + $deviceFields.Count)
    foreach ($currentField in $deviceFields) {
        $currentField.ToString()
        If ($first -eq $True) {
            $outputString = $currentField
            $first = $false
        } Else {
            $outputString += $separator + $currentField
        }
    }
    
    Return $outputString
}

$concateUserInfo = $userName + ":" + $password
$restUserName = Get-BasicUserForAuth ($concateUserInfo)

$useJSON = "application/json"
$headers = Build-Headers $restUserName $tenantAPIKey $useJSON $useJSON
$changeURL = $endpointURL + "/API/system/groups/$id/tags"
Write-Verbose "------- Web call URL -------"
Write-Verbose $changeURL
Write-Verbose "----------------------------"
$webReturn = Invoke-RestMethod -UserAgent C15IE72011A -Uri $changeURL -Headers $headers -Proxy "http://proxy.apps.dhs.gov:80/" -ContentType $useJSON
$string = ConvertTo-Json -InputObject $webReturn
$tags = ConvertFrom-Json -InputObject $string
foreach ($tag in $tags.Tags) {
    Export-Csv -InputObject $tag -Path .\my.csv -Append -NoTypeInformation
}
if ($outputFile) {
    Out-File -filepath $outputFile -InputObject $string
}
Write-Verbose $string
