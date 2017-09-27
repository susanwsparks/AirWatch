#!/bin/bash
# Bash script for Joining Domain with Centrify
#
# Exit code 0 = successful
# Exit code 1 = missing username
# Exit code 2 = missing password
# Exit code 3 = missing container
# Exit code 4 = missing workstation type
# Exit code 5 = Failed to perform licensing.
# Exit code 6 = Failed to join AD.
# Exit code 7 = Failed to enable centrify
# Exit code 8 = Failed to find hostname"
#
# Usage: ./Centrifyinstall_Z.command 'svcaccountname' 'svcaccountpass' 'OU=Computers,DC=example,DC=com' 'domain' 'base_log' 'error_log'
# Gather all the variables and locally store them.
#

# $3 is the container
container="$3"

# $4 is the workstation
workstation="$4"

# $5 is the generic log
base_log="$5"

# $6 is the error log
error_log="$6"

hostname=$(hostname -s)
hostname=$(echo $hostname | awk '{print toupper($0)}')

# For now if container is not set already, specify it manually
#[[ -z $container ]] && container=$(/usr/bin/defaults read "$CustomAttrPath" hostOUInfo 2>/dev/null)
[[ -z $container ]] && container="OU=Computers,OU=HQ1,OU=NCR,DC=cis1,DC=cisr,DC=uscis,DC=dhs,DC=gov"

# For now if the workstation is not set already, specify it manually
[[ -z $workstation ]] && workstation="cis1.cisr.uscis.dhs.gov"

# If logs are not specified in line, direct what to write
[[ -z $base_log ]] && base_log="/var/log/Centrifyinstall_Z.gen.log"
[[ -z $error_log ]] && error_log="/var/log/Centrifyinstall_Z.err.log"

# Attempt to ping the domain. No use running if we can't even see it.
/sbin/ping 10.61.70.250 -c 4 >/dev/null 2>&1
pingstat=$?

[[ $pingstat > 0 ]] && exit

# PlistBuddy Path
PlistBuddy="/usr/libexec/PlistBuddy"

# Cocoa Dialog Binary
CD="/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog"

# The Custom Attributes Path to file.
CustomAttrPath="/Library/Application Support/AirWatch/Data/CustomAttributes/CustomAttributes.plist"

Usage() {
    local errorcode="$1"
    case $errorcode in
        0)
		    $CD ok-msgbox --float --title "Joined Successfully" --no-newline --informative-text "Configured and Joined domain Successfully." --button1 "OK" --quiet
			launchctl unload /Library/LaunchDaemons/com.centrify.domainjoin.plist 2>>"${error_log}" 1>>"${base_log}" 2>&1
			rm -rf /Library/LaunchDaemons/com.centrify.domainjoin.plist 2>>"${error_log}" 1>>"${base_log}" 2>&1
			;;
        1) $CD ok-msgbox --float --title "Username invalid" --no-newline --informative-text "Please enter the -admin account username." --button1 "OK" --quiet ;;
        2) $CD ok-msgbox --float --title "Password invalid" --no-newline --informative-text "Please enter the -admin account password." --button1 "OK" --quiet ;;
        5) $CD ok-msgbox --float --title "Centrify Licensing Failed" --no-newline --informative-text "Failed to perform centrify licensing." --button1 "OK" --quiet ;;
        6) $CD ok-msgbox --float --title "Centrify Failed Domain Join" --no-newline --informative-text "Failed to join to domain." --button1 "OK" --quiet ;;
        7) $CD ok-msgbox --float --title "Smart card enable Failed" --no-newline --informative-text "Failed to enable smartcards with centrify." --button1 "OK" --quiet ;;
        9) $CD ok-msgbox --float --title "Domain Not found" --no-newline --informative-text "Unable to communicate with domain." --button1 "OK" --quiet ;;
		*) $CD ok-msgbox --float --title "Unknown Issue Occurred" --no-newline --informative-text "Something failed, though we do not know what." --button1 "OK" --quiet ;;
    esac
    if [[ $errorcode -gt 0 ]] ; then
	    $CD ok-msgbox --float --title "Try Again Shortly" --informative-text "The prompts will try again shortly, during this time you may need to recheck your XCeedium Password.

If you are in a hurry, you can manually rerun, but this requires root privileges on this machine.

From Terminal, run:

su - <adminusername>

Enter password as required.

Run:

sudo -i

Re-enter password as required.

Run:

bash ~/.hideme/centrifyadjoin.sh" --button1 "OK" --quiet
		echo "Usage: $0 'username' 'password' 'container' 'workstation/domain' ['/path/for/generic/log'] ['/path/for/error/log']"
    fi
    exit $errorcode
}

# Gather all the variables and locally store them.
#
# $1 is the svcaccount name
svcaccountname=$($CD inputbox --float --title "Active Directory -admin username" --no-newline --informative-text "Please enter your Active Directory -admin account name. NOTE: You should already have your -admin account's password as issued by XCeedium" --button1 "OK" --quiet | tail +2)

# $2 is the svcaccount pass
svcaccountpass=$($CD secure-inputbox --float --title "Active Directory -admin password" --no-newline --informative-text "Please enter your Active Directory -admin password as issued by Xceedium" --button1 "OK" --quiet | tail +2)

# $3 is the container
container="$3"

# $4 is the workstation
workstation="$4"

# $5 is the generic log
base_log="$5"

# $6 is the error log
error_log="$6"

hostname=$(hostname -s)
hostname=$(echo $hostname | awk '{print toupper($0)}')

# For now if container is not set already, specify it manually
#[[ -z $container ]] && container=$(/usr/bin/defaults read "$CustomAttrPath" hostOUInfo 2>/dev/null)
[[ -z $container ]] && container="OU=Computers,OU=HQ1,OU=NCR,DC=cis1,DC=cisr,DC=uscis,DC=dhs,DC=gov"

# For now if the workstation is not set already, specify it manually
[[ -z $workstation ]] && workstation="cis1.cisr.uscis.dhs.gov"

# If logs are not specified in line, direct what to write
[[ -z $base_log ]] && base_log="/var/log/Centrifyinstall_Z.gen.log"
[[ -z $error_log ]] && error_log="/var/log/Centrifyinstall_Z.err.log"

# Tests our "required" variables being setup properly

# Tests if service account name is set, if not throws an error and exits
[[ -z $svcaccountname ]] && Usage 1

# Tests if service account pass is set, if not throws an error and exits
[[ -z $svcaccountpass ]] && Usage 2

# Tests if the container element is set, if not throws an error and exits
[[ -z $container ]] && Usage 3

# Tests if the workstation element is set, if not throws an error and exits
[[ -z $workstation ]] && Usage 4

# Tests if the hostname is set, if not throws an error and exits
[[ -z $hostname ]] && Usage 8

# Starts logging
echo "Starting Centrify joining Scripts" >"${base_log}"
echo >>"${base_log}"

# Add Licensing
echo >>"${base_log}"
echo "Preparing to license via cmd: /usr/local/bin/adlicense -l" >>"${base_log}"
echo >>"${base_log}"
/usr/local/bin/adlicense -l 1>>"${base_log}" 2>>"${error_log}"
adlicenseStatus="$?"
# Tests status of the adlicense tool.
[[ $adlicenseStatus > 0 ]] && Usage 5

# Join Domain
# This appears to disconnect the existing session
# Adding with -e (Should try using apples guid stuff)
# Adding with -V (More verbosity)
# Adding with -f (So we can see if it can work on top)
# Adding with -t (License type to use)
echo >>"${base_log}"
echo "Attempting to join domain using cmd: /usr/local/sbin/adjoin -u \"[user]\" -p \"[pass]\" -c \"[container]\" -w \"[domain]\" -e -V -f -t workstation" >>"${base_log}"
echo >>/var/log/Centrifyinstall_Z.log
/usr/local/sbin/adjoin -u "${svcaccountname}" -p "${svcaccountpass}" -c "${container}" -w "${workstation}" -n "${hostname}" -e -V -f -t workstation 1>>"${base_log}" 2>>"${error_log}"
adjoinStatus="$?"

# Tests status of the adjoin
[[ $adjoinStatus > 0 ]] && Usage 6

# Enable Centrify Smart Card
# NOTE: Can only be done when the domain is joined.
echo >>"${base_log}"
echo "Enabling Centrify using cmd: /usr/local/bin/sctool -e" >>"${base_log}"
echo >>"${base_log}"
/usr/local/bin/sctool -e 1>>"${base_log}" 2>>"${error_log}" 2>&1
sctoolStatus="$?"

# Tests status of the sctool
[[ $sctoolStatus > 0 ]] && Usage 7

# Success of all
$PlistBuddy -c 'Add :centrifyDomainJoin string yes' "$CustomAttrPath" >/dev/null 2>&1 || $PlistBuddy -c 'Set :centrifyDomainJoin yes' "$CustomAttrPath" >/dev/null 2>&1

# Now that we are successfully joined remove the repeat checks.
Usage 0