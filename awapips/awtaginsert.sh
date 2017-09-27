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
[[ -z $configfile ]] && configfile="$HOME/.awupdaterc"
[[ -z $filename ]] && filename="addtag.csv"
if [[ ! -f $filename ]]; then
    echo "No data to add"
    exit 1
fi
# Takes the .awupdaterc and sources its information
# into the script.
[[ -f $configfile ]] && . $configfile
# Probably not needed, but helps clarify our content type.
contenttype="Content-Type: application/json"
# Sets header for aw-tentant-code
toknString=$(echo "aw-tenant-code: ${AirwatchAPIToken}")
# If AirwatchAPIURL is not defined, set it to our default.
[[ -z $AirwatchAPIURL ]] && AirwatchAPIURL="https://uscisprodconsole.awfed.com/"
# Pull in our serial numbers from the csv file.
read tags <<< $(awk -F[,] '{print $1}' $filename)
# Loop through our serial numbers.
for tag in $tags; do
    # If the first line is header, skip it (Could appear anywhere in the csv I suppose.
    [[ $tag =~ [Tt][Aa][Gg] ]] && continue
    # Get the serial's corresponding AssetNumber.
    read typeid location <<< $(awk -F[,] '/'$serial'/{printf("%s %s", $2, $3}' $filename)
    # Supout this item's change url.
    changeURL="${AirwatchAPIURL}/API/system/groups/$location/addTag"
    # Just stores the passed information to a file so user can review if something went wrong.
    echo "{\"TagName\": \"$tag\",\"TagType\": $typeid, \"LocationGroupId\": $locationid}" >tmp${tag}.json
    # Perform the change
    curl --user $username:$password -H "${contenttype}" -H "${toknString}" "${changeURL}" -d "$(cat tmp${tag}.json)"
    # Sleep half a second
    sleep 0.5
done

