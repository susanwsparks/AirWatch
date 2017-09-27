# awapips
AirWatch API Powershell scripts and example CSV File

Update Device Names within AirWatch.

1.	Download Script:
 1. https://git.uscis.dhs.gov/tgelliot/awapips/
 2.	Click “Clone Or download->Download Zip”
 3.	Extract files once downloaded.
2.	CSV Format:
 1.	Must contain Headers: SerialNumber,AssetNumber
 2.	Serial format can contain the S as brought in when Barcode scanned in. This S (as long as it’s the first character) will be removed automatically.
 3.	AssetNumber must contain the full string as you expect it to apper.
 4.	Space can exist at the beginning and end of items.
   * ` SomeSerial , LABabcefg ` would be valid and enter correctly within the AW system as we trim the extra whitespace.
3.	Open Powershell
 1.	May require administrator level opening
 2.	Once opened, may require setting execution policy with:
   *	`Set-ExecutionPolicy -Scope User Unrestricted`
 3.	Edit the awupdate.ps1 file at lines 28 through 30. Edit the username password and token elements.
   * Username, Password, and Token should reflect per your setup.
   * You can also change the AirwatchAPIURL as needed.
 4.	Run the script within powershell prompt:
   * `cd \path\to\extracted\files`
    * `.\awupdate.ps1 -inputFile \path\to\csvfile`

##### NOTE: If you only have one asset/serial to update it’s possible an error will be returned as it is trying to work off a loop. If you’re concerned something didn’t work right, check within the AW Console to verify if it did or didn’t work as expected.

##### NOTE: This only updates existing items within the console. If you see errors on devices failing to be updated, chances are the device doesn’t exist within the console.
