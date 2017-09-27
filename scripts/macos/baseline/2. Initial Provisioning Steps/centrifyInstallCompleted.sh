#!/bin/sh

PlistBuddy="/usr/libexec/PlistBuddy"

$PlistBuddy -c 'Add :centrifyInstallComplete string yes' /Library/Application\ Support/AirWatch/Data/CustomAttributes/CustomAttributes.plist