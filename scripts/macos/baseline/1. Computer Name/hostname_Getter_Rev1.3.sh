#!/bin/bash

# The idea here is to build a series of select items.
# These will help place our host into the matching OU
# within Active directory and make our hostname
# setup that little bit more dynamic. On top of this
# it will build the entire hostname and we will store
# the CIS Tag, OU, DNS Name as AD will expect, and hostname
# of this device for later lookups.

# Get the CocoaDialog Binary location.
CD="/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog"

# Path to PlistButty
PB="/usr/libexec/PlistBuddy"

# Path to custom attributes
AWCPath="/Library/Application Support/AirWatch/Data/CustomAttributes/CustomAttributes.plist"

# Asks if this is a Laptop/MacBook or not.
function laptop() {
    # The our two options.
    local systype=("Yes" "No")

    # Display and get returned data from user.
    local pctype=$($CD standard-dropdown --title "MacBook" --no-newline --text "Is the device a MacBook/Laptop?" --items "${systype[@]}" | tail +2)

    # Start setting up the hostname.
    [[ $pctype -eq 0 ]] && hostname="L" || hostname="D"
}

# Gets the sitecode from the user and helps build the OU and hostname parameters.
function sitecode() {
    # The top level site codes.
    local TOP_LEVEL=("CRO" "FOR" "NAT" "NCR" "NER" "SCA" "SER" "WRO")

    # The low level site codes. Based on the selected top level.
    local CRO=("D12" "D13" "D14" "D15" "D16" "D17" "D18" "D19")
    local FOR=("BKK" "MEX" "OCO" "RAD" "REF" "RIT")
    local NAT=("BEV" "CBN" "CIS" "CRO" "CSC" "EFC" "ENO" "ETC" "FSC" "HBG" "HQT" "LPF" "NBC" "NER" "NHC" "NRC" "NSC" "NVOC" "OSI" "RDF" "TSC" "TTC" "VSC" "WFC" "WLS" "WRO" "WTC")
    local NCR=("CCV" "D06" "D07" "HGB" "HQ1" "HQT")
    local NER=("D01" "D02" "D03" "D04" "D05")
    local SCA=("CRO" "D16" "D17" "D18" "TSC")
    local SER=("D08" "D09" "D10" "D11")
    local WRO=("D20" "D21" "D22" "D23" "D24" "D25" "D26")

    # Ask user which top level they belong under.
    local top=$($CD standard-dropdown --float --title "Base Site Code" --text "Please select Top level site code:" --items "${TOP_LEVEL[@]}" --string-output | tail +2)

    # Get the selector based on the top level site code.
    local sel="$top[@]"

    # Ask user which low level they belong under.
    local low=$($CD standard-dropdown --float --title "My Site Code" --text "Please select your site code:" --items "${!sel}" --string-output | tail +2)

    # Uses the low and top variables to set the OU structure we need later on.
    ou="OU=Computers,OU=$low,OU=$top,DC=cis1,DC=cisr,DC=uscis,DC=dhs,DC=gov"

    # Initialize the hlow variable
    local hlow=''

    # Ask the user to type in the three digit site code the hostname will be requiring.
    while [[ -z $hlow ]]
    do
        # Display the dialog and return the input to the hlow variable.
        hlow=$($CD inputbox --float --title "Host Site Code" --no-newline --informative-text "Please enter the site code your computer falls within:" --button1 "OK" --string-output | tail +2)
        # Trim out all non alpha numeric characters.
        hlow="${hlow//[^[:alnum:]]/}"
        # Capitalize
        hlow=$(echo ${hlow} | tr '[[:lower:]]' '[[:upper:]]')
        # Get the number of characters.
        hlowsize=${#hlow}
        # Tests the input to ensure it's meeting our standards. Cannot be empty and must contain 3 characters.
        if [[ -z $hlow || ! $hlowsize -eq 3 ]]; then
            $CD ok-msgbox --float --title "Invalid input" \
                --text "The input you entered is invalid." --quiet \
                --informative-text "The input you entered must be 3 characters. Spaces do not count."
            hlow=''
            continue
        fi
        # More refined test that the three characters are alpha-numerica
        case "$hlow" in
            [^A-Z0-9])
                $CD ok-msgbox --float --title "Invalid input" \
                    --text "The input you entered is invalid." --quiet \
                    --informative-text "The input you entered cannot contain any special characters. Only Alpha-Numeric data please."
                hlow=''
                ;;
        esac
    done
    # Continue setting up the hostname.
    hostname="${hostname}M${hlow}CIS"
}

# Gets the asset tag from the user
function assettag() {
    # Initialize our assetTag variable
    assetTag=''
    # Start our requests and tests.
    while [[ -z $assetTag ]]
    do
        # First input
        asset1=$($CD inputbox --float --title "CIS Asset Tag" --no-newline --informative-text "Please enter your system's asset tag (e.g. ######)" --button1 "OK" --quiet | tail +2)
        asset1=${asset1//[^[:digit:]]/}
        # Confirmation input
        asset2=$($CD inputbox --float --title "CIS Asset Tag" --no-newline --informative-text "Please enter your system's asset tag again (e.g. ######)" --button1 "OK" --quiet | tail +2)
        asset2=${asset2//[^[:digit:]]/}
        # Get the size of the a1 field.
        sizeA1=${#asset1}
        # If either the asset inputs are blank or they do not match or the first asset tag is not the right length, inform the user and recycle.
        if [[ -z $asset1 || -z $asset2 || $asset1 != $asset2 || ! $sizeA1 -eq 6 ]]
        then
            $CD ok-msgbox --float --title "Invalid Input" \
                --text "The inputs you entered are invalid." \
                --informative-text "The inputs you entered do not match or are not 6 numeric digits. You will be requested to enter this information again."
            continue
        fi
        # Set our asset tag variable.
        assetTag="$asset1"
    done
    # Finished setting up the hostname.
    hostname="${hostname}${assetTag}"
}

# Gets the hostname from the user
function hostnamegetter() {
    # Initialize our hostname variable
    hostname=''
    while [[ -z $hostname ]]
    do
        $CD ok-msgbox --float --title "Hostname Information" \
            --text "Preparing to set computername / hostname." \
            --informative-text "When you click OK, you will be prompted to enter this devices computer name.
			
Make sure to follow the approved naming conventions for Apple devices.

Active Directory must contain this computer object prior to domain joining (The next step in the process.)

IMPORTANT: You MUST complete this action within 10 minutes of this prompt, otherwise it will automatically close.

IMPORTANT: Do NOT cancel this prompt, or it will stop you from successful provisioning.

In either situation, you will need to contact somebody with access to AirWatch console to re-initiate the provisioning steps." --quiet
        # First input
        hostname1=$($CD inputbox --float --title "Hostname" --no-newline --informative-text "Please enter the hostname for this system. (e.g. LMBEVCIS123456)" --button1 "OK" --quiet | tail +2)
        hostname1=${hostname1//[^[A-Za-z0-9]]/}
        hostname2=$($CD inputbox --float --title "Hostname" --no-newline --informative-text "Please reenter the hostname for this system. (e.g. LMBEVCIS123456)" --button1 "OK" --quiet | tail +2)
        hostname2=${hostname2//[^[A-Za-z0-9]]/}
        sizeHN1=${#hostname1}
        hn1=$(echo $hostname1 | tr '[:upper:]' '[:lower:]')
        hn2=$(echo $hostname2 | tr '[:upper:]' '[:lower:]')
        if [[ -z $hn1 || -z $hn2 || $hn1 != $hn2 || $sizeHN1 -gt 15 ]]
        then
            $CD ok-msgbox --float --title "Invalid Input" \
                --text "The inputs you entered are invalid." \
		--informative-text "The inputs you entered do not match, or are greater than 15 characters. You will be requested to enter this information again."
            continue
        fi
	# Set our hostname variable
        hostname=$(echo $hn1 | tr '[:lower:]' '[:upper:]')
    done
}

# Is the device MacBook or not?
#laptop

# What is the site code for this device?
#sitecode

# What is the asset tag for this device?
#assettag

# Get hostname
hostnamegetter

# Now that we have an OU and hostname, lets create our custom attributes for these things.
#$PB -c "Add :cisAssetTag string CIS${assetTag}" "$AWCPath" >/dev/null 2>&1 || $PB -c "Set :cisAssetTag CIS${assetTag}" "$AWCPath" >/dev/null 2>&1
#$PB -c "Add :hostOUInfo string ${ou}" "$AWCPath" >/dev/null 2>&1 || $PB -c "Set :hostOUInfo ${ou}" "$AWCPath" >/dev/null 2>&1
$PB -c "Add :hostname string ${hostname}" "$AWCPath" >/dev/null 2>&1 || $PB -c "Set :hostname ${hostname}" "$AWCPath" >/dev/null 2>&1
$PB -c "Add :hostnameFQDN string ${hostname}.cis1.cisr.uscis.dhs.gov" "$AWCPath" >/dev/null 2>&1 || $PB -c "Set :hostnameFQDN ${hostname}.cis1.cisr.uscis.dhs.gov" "$AWCPath" >/dev/null 2>&1
# Now let's update the hostname for this system.
/usr/sbin/scutil --set HostName ${hostname}
/usr/sbin/scutil --set ComputerName ${hostname}
/usr/sbin/scutil --set LocalHostName ${hostname}
/bin/hostname $hostname
# Now that host name setting is complete, set our custom attribute.
$PB -c "Add :hostnameSetComplete string yes" "$AWCPath" >/dev/null 2>&1 || $PB -c "Set :hostnameSetComplete yes" "$AWCPath" >/dev/null 2>&1

$CD ok-msgbox --float --title "Hostname Changed" \
    --text "Hostname changed to $hostname" \
    --quiet

# Do other things later on.
#defaults write /Library/Preferences/com.apple.security.smartcard DisabledTokens -array com.apple.CryptoTokenKit.pivtoken >/dev/null 2>&1
#exit 0
