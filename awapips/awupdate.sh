#!/bin/bash
#
# Pulls data in (username, password, api url) from awupdaterc file
# NOTE:
#  If no awupdaterc file is found you may call the script with
#   the needed variables. Example:
# username="apiusername" password="apiusernamepassword" AirwatchAPIToken="APIToken" awupdate.sh
#  If you do not have hte awupdaterc and you do not call the script setting the variables with it, it
#   most likely will not work.
# Takes the CSV in form SerialNumber,AssetNumber and updates
# The entry in airwatch.
if [[ ! -f changeasset.csv ]]; then
    echo "No data to update/edit"
    echo "Either pass serialnumbers as an argument or provide the"
    echo " changeasset.csv file in your working directory."
    exit 1
fi
# Takes the .awupdaterc and sources its information
# into the script.
[[ -f $HOME/.awupdaterc ]] && . $HOME/.awupdaterc
# Probably not needed, but helps clarify our content type.
contenttype="Content-Type: application/json"
# Sets header for aw-tentant-code
toknString=$(echo "aw-tenant-code: ${AirwatchAPIToken}")
# If AirwatchAPIURL is not defined, set it to our default.
[[ -z $AirwatchAPIURL ]] && AirwatchAPIURL="https://uscisprodconsole.awfed.com/"
# Pull in our serial numbers from the csv file.
read serialnumbers <<< $(awk -F[,] '{print $1}' changeasset.csv)
# Loop through our serial numbers.
for serial in $serialnumbers; do
    # If the first line is header, skip it (Could appear anywhere in the csv I suppose.
    [[ $serial =~ [Ss][Ee][Rr][Ii][Aa][Ll] ]] && continue
    # Strip the leading S from the serial number
    serial=${serial#"S"}
    # Get the serial's corresponding AssetNumber.
    read asset <<< $(awk -F[,] '/'$serial'/{print $2}' changeasset.csv)
    # Supout this item's change url.
    changeURL="${AirwatchAPIURL}/API/mdm/devices/serialnumber/$serial/editdevice"
    # Just stores the passed information to a file so user can review if something went wrong.
    echo "{\"AssetNumber\": \"$asset\"}" >tmp${serial}.json
    # Perform the change
    curl --user $username:$password -H "${contenttype}" -H "${toknString}" "${changeURL}" -d '{"AssetNumber":"'$asset'"}'
    # Sleep half a second
    sleep 0.5
done

