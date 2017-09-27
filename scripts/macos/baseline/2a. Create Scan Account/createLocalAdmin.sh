#!/bin/bash

# Creates the local administator account we require.

# Path to PlistButty
PB="/usr/libexec/PlistBuddy"

# Path to custom attributes
AWCPath="/Library/Application Support/AirWatch/Data/CustomAttributes/CustomAttributes.plist"

# The binary run point.
dscl="/usr/bin/dscl"

# Create the new user we need.
$dscl . -create /Users/cisscan
$dscl . -create /Users/cisscan Picture "/Library/User Pictures/Animals/Eagle.tif"
$dscl . -create /Users/cisscan RealName "CIS Scan"
$dscl . -create /Users/cisscan UniqueID 503
$dscl . -create /Users/cisscan PrimaryGroupID 20
$dscl . -create /Users/cisscan UserShell /bin/bash
$dscl . -passwd /Users/cisscan 'nGH3$yrsR85[a4EDq*glb79m'

# Add to sudoers
/bin/echo "cisscan ALL=(ALL) ALL" >> /etc/sudoers

# Group Membership
$dscl . append /Groups/admin GroupMembership cisscan

# Set up hidden folder
$dscl . -create /Users/cisscan NFSHomeDirectory /Users/cisscan /dev/null 2>&1
/usr/sbin/chown -R cisscan:staff /Users/cisscan >/dev/null 2>&1 || true

# create the home folder
/usr/sbin/createhomedir -cu cisscan

# Remove the public folder for CIS Admin
/bin/rm -R /Users/cisscan/Public >/dev/null 2>&1 || true

$PB -c "Add :scanAcctCreated string yes" "${AWCPath}" >/dev/null 2>&1 || $PB -c "Set :scanAcctCreated yes" "${AWCPath}" >/dev/null 2>&1

