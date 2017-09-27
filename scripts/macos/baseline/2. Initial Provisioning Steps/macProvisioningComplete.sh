#!/bin/bash -x

PlistBuddy="/usr/libexec/PlistBuddy"
CustomAttrPath="/Library/Application Support/AirWatch/Data/CustomAttributes/CustomAttributes.plist"

$PlistBuddy -c 'Add :macProvisioningComplete string yes' "$CustomAttrPath" >/dev/null 2>&1 || $PlistBuddy -c 'Set :macProvisioningComplete yes' "$CustomAttrPath" >/dev/null 2>&1
