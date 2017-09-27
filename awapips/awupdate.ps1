
<# Execute-AWRestAPI Powershell Script Help

  .SYNOPSIS
    This Poweshell script make a REST API call to an AirWatch server.  This particular script is used to update the devices AssetNumber matching the passed in Serial.

  .USAGE
    Edit the powershell and change the userName, password, and tenantAPIKey to match
    the information given to you by AirWatch. As needed update your endpointURL as well.

  .PARAMETER inputFile)
    This is the complete path and filename to the relevant csv file.

  .PARAMETER outputFile (optional)
    This is not required.  If you don't specify this parameter on the command line, the script will just show

  .PARAMETER configFile (optional)
    This is not required.  If you don't specify this parameter on the command line, the script will just show
#>

[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$inputFile,

        [Parameter()]
        [string]$outputFile,

        [Parameter()]
        [string]$configFile
)

If (!$PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
    $ErrorActionPreference = "SilentlyContinue"
}

if (!$configFile) {
    $configFile = ".\awupdaterc.ps1"
}

. $configFile

<#
  This implementation uses Baisc authentication.  See "Client side" at https://en.wikipedia.org/wiki/Basic_access_authentication for a description
  of this implementation.
#>
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

$failed = @()
If ($inputFile) {
    If (Test-Path $inputFile) {
        $useJSON = "application/json"
        $headers = Build-Headers $restUserName $tenantAPIKey $useJSON $useJSON
        $quoteCharacter = [char]34
        $serialNumbers = Import-Csv $inputFile
        $newDate = $(get-date -f yyyy-MM-dd)
        ForEach ($serialNumber in $serialNumbers) {
            $serial = $serialNumber.SerialNumber
            $serial = $serial.Trim()
            $serial = $serial.TrimStart('S')
            $asset = $serialNumber.AssetNumber
            $asset = $asset.Trim()
            $bulkRequestObject = "{" + $quoteCharacter + "AssetNumber" + $quoteCharacter + ":" + $quoteCharacter + $asset + $quoteCharacter + "}"
            Write-Verbose "------- JSON to Post---------"
            Write-Verbose $bulkRequestObject
            Write-Verbose "-----------------------------"
            Write-Verbose ""
            $changeURL = $endpointURL + "/API/mdm/devices/serialnumber/" + $serial + "/editdevice"
            Write-Verbose "------- Web call URL---------"
            Write-Verbose $changeURL
            Write-Verbose "-----------------------------"
            if (Invoke-RestMethod -UserAgent C15IE72011A -Method Post -Uri $changeURL -Headers $headers -Body $bulkRequestObject -Proxy "http://proxy.apps.dhs.gov:80/") {
                Start-Sleep -m 500
                continue
            } else {
                $details = @{
                    SerialNumber = $serial
                    AssetNumber = $asset
                }
                $failed += New-Object PSObject -Property $details
            }
            Start-Sleep -m 500
        }
        $failed | export-csv -Path DoesNotExist_$newDate.csv -NoTypeInformation -Encoding ASCII -Append
    } Else {
        Write-Host ("File: " + $inputFile + " not found.")
    }
}
