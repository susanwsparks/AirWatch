#!/bin/bash
# Bash macOS Hardening script.

# 2.4 Remote Access Monitoring
#  You may also edit the /etc/security/audit_control file using a text editor to define the flags your organization requires for auditing.
/usr/bin/sed -i.bak '/^flags/ s/$/,lo/' /etc/security/audit_control 2>/var/log/hardening.log 2>&1

# 2.5	Encrypt Remote Access (Disable rexec)
/usr/bin/defaults write /private/var/db/launchd.db/com.apple.launchd/overrides.plist 'com.apple.rexecd' -dict Disabled -bool true 2>>/var/log/hardening.log 2>&1

# 2.6	Encrypt Remote Access (Disable telnet)
/usr/bin/defaults write /private/var/db/launchd.db/com.apple.launchd/overrides.plist 'com.apple.telnetd' -dict Disabled -bool true 2>>/var/log/hardening.log 2>&1

# 2.7	Disable Remote Shell (rshd)
/usr/bin/defaults write /private/var/db/launchd.db/com.apple.launchd/overrides.plist 'com.apple.rshd' -dict Disabled -bool true 2>>/var/log/hardening.log 2>&1

# 2.8    Ignored - Disable Screen Sharing
# Ignored defaults write /private/var/db/launchd.db/com.apple.launchd/overrides.plist 'com.apple.screensharing' -dict Disabled -bool true

# 2.9 Display Banner on Any Remote Interface # No changes

# 2.10 Password Complexity
# Ignored  Password policy is applied by configuration profile

# 2.11 Password Length
# Ignored  Password policy is applied by configuration profile

# 2.12 Protected Password Transmission - disable telnet # ignored - same policy as 2.6

# 2.13 SEncrypt Non-Local Maintenance Sessions - disable telnet # ignored, solution is exactly the same as 2.6

# 2.14 Strong Authentication for Non-Local Maintenance - disable telnet # ignored, solution is exactly the same as 2.6

# 2.15 Set SSH ClientAliveInterval
/usr/bin/sed -i.bak 's/.*ClientAliveInterval.*/ClientAliveInterval 600/' /etc/sshd_config 2>>/var/log/hardening.log 2>&1

# 2.16 Set SSH ClientAliveCountMax
/usr/bin/sed -i.bak 's/.*ClientAliveCountMax.*/ClientAliveCountMax 0/' /etc/sshd_config 2>>/var/log/hardening.log 2>&1

#2.17	Set SSH LoginGraceTime
/usr/bin/sed -i.bak 's/.*LoginGraceTime.*/LoginGraceTime 30/' /etc/sshd_config 2>>/var/log/hardening.log 2>&1

#2.18 Obtain Valid Public Key Certificates # Ignored, Part of deployment image for laptops, no changes

#2.19 Enable Disk Encryption
# Done as part of config profile

#2.20 Establish Firmware Password
# Ignored

#2.21 Disable Automatic Logon
# No Changes, Part of standard image

#2.22 Disable list of users
# Part of one image requirements

#2.23 Require  Command Authentication
# Ignored

#2.24 Empty Trash Securely
# Ignored

#2.25 Enable Secure Virtual Memory
/usr/bin/defaults write /Library/Preferences/com.apple.virtualMemory DisableEncryptedSwap -bool false 2>>/var/log/hardening.log 2>&1

#2.26 Lock on Consecutive Invalid Logons #Ignored, authentication and lockout is controlled by configuration policy

#2.27

#2.28 Require PKI (PIV) Authentication
# Ignored - Centrify PIV authentication

#3.1 to 3.6  Part of ICE requirements for, no changes


#3.9 Disable usbmuxd
/bin/launchctl unload -w /System/Library/LaunchDaemons/com.apple.usbmuxd.plist 2>&1

# 3.10 Enable Fireloging - ignored due to poor documentation provided by DHS
# /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on

#3.11 Disable Remote Apple Events - ignored

#3.12 Disable finger service
/usr/bin/defaults write /private/var/db/launchd.db/com.apple.launchd/overrides.plist 'com.apple.fingerd' -dict Disabled -bool true 2>>/var/log/hardening.log 2>&1

#3.13 Disable iTunes Music Sharing - disabled in USCIS Configuration Profile

#3.14 to 3.29


#3.30 Disable Bonjour Advertising when not required
/usr/libexec/PlistBuddy -c 'Add :ProgramArguments:2 string '-NoMulticastAdvertisements'' /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist 2>>/var/log/hardening.log 2>&1

#3.31 Disable Unix to Unix Copy uucp
/usr/bin/defaults write /private/var/db/launchd.db/com.apple.launchd/overrides.plist 'com.apple.uucp' -dict Disabled -bool true 2>>/var/log/hardening.log 2>&1

#4.1 to 4.5 Disable Automatic Actions for Blank CDs -ignore. Modern Macs do not use CDROMS

#4.6 Restrict USB Devices - ignored, users would not be able to work w/o USB

#5.1 to 5.2 N/A

#5.3 Automatically Audit Account Creation sed -i.bak '/^flags/ s/$/,ad/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#5.4 to 5.6, solution is exactly the same as 5.3

#5.7 to 5.8, see ICE OS X 10.10 Hardening guide

#5.9 User Account Remote Authentication
/usr/bin/sed -i.bak 's/.*Protocol.*/Protocol 2/' /etc/sshd_config 2>>/var/log/hardening.log 2>&1

#6.1	Disable SMB File Sharing - USCIS uses SMB file sharing
#/private/var/db/launchd.db/com.apple.launchd/overrides.plist 'com.apple.smbd' -dict Disabled -bool true

#6.2 Disable Apple File Sharing
/usr/bin/defaults write /private/var/db/launchd.db/com.apple.launchd/overrides.plist 'com.apple.AppleFileServer' -dict Disabled -bool true 2>>/var/log/hardening.log 2>&1

#6.3 Disable NFS Daemon
/usr/bin/defaults write /private/var/db/launchd.db/com.apple.launchd/overrides.plist 'com.apple.nfsd' -dict Disabled -bool true 2>>/var/log/hardening.log 2>&1

#6.4 Disable NFS Lock Daemon
/usr/bin/defaults write /private/var/db/launchd.db/com.apple.launchd/overrides.plist 'com.apple.lockd' -dict Disabled -bool true 2>>/var/log/hardening.log 2>&1

#6.5	Disable NFS Stat Daemon
/usr/bin/defaults write /private/var/db/launchd.db/com.apple.launchd/overrides.plist 'com.apple.statd.notify' -dict Disabled -bool true 2>>/var/log/hardening.log 2>&1

#6.6 	Set Global umask for User Applications -ignored

#6.7	Set Global umask for System Processes
/bin/sh -c 'echo 'umask 022' > /etc/launchd.conf' 2>>/var/log/hardening.log 2>&1

#6.8	Protect Public Directories

#6.9	Set Sticky Bit on Public Directories -ignored

#6.10	Disable Internet Sharing
/usr/bin/defaults write /private/var/db/launchd.db/com.apple.launchd/overrides.plist 'com.apple.InternetSharing' -dict Disabled -bool true 2>>/var/log/hardening.log 2>&1

#6.11 Disable Web Sharing
/usr/bin/defaults write /private/var/db/launchd.db/com.apple.launchd/overrides.plist 'org.apache.httpd' -dict Disabled -bool true 2>>/var/log/hardening.log 2>&1

#6.12	Disable Airdrop
#net.inet6.ip6.forwarding=0

#7.1	Audit Privileged Activities
/usr/bin/sed -i.bak '/^flags/ s/$/,ad/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.2	Audit Logon Attempts
/usr/bin/sed -i.bak '/^flags/ s/$/,aa/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.3	Enable Audits at System Startup
/bin/launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist 2>>/var/log/hardening.log 2>&1

#7.4	Audit Defined Events
/usr/bin/sed -i.bak '/^flags/ s/$/,lo,ad,aa/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.5	Audit Account Change Events
/usr/bin/sed -i.bak '/^flags/ s/$/,ad/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.6	Maintain Audit Records for Minimum Period
/usr/bin/sed -i.bak 's/.*expire-after.*/expire-after:90d/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.7	Alert on Audit Storage Near Capacity
/usr/bin/sed -i.bak 's/.*minfree.*/minfree:25/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.8	Real-time Alert on Audit Failure
/usr/bin/sed -i.bak 's/logger -p/logger -s -p/' /etc/security/audit_warn 2>>/var/log/hardening.log 2>&1

#7.9	Proper Audit Log File Permissions - ignored

#7.10	Proper Audit Log File Folder Permissions -ignored

#7.11	No Audit Log File Normal User Permission ACLs - ignored

#7.12	Protect Audit Log File Integrity - ignored

#7.13	Proper Log File Creation -ignored

#7.14	Shutdown on Audit Failure - Added with concern
/usr/bin/sed -i.bak '/^policy/ s/$/,ahlt/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.15	Audit System Kernel Module Actions
/usr/bin/sed -i.bak '/^flags/ s/$/,ad/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.16	Audit Attempts to Modify Security Objects
/usr/bin/sed -i.bak '/^flags/ s/$/,fm/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.17	Audit Attempts to Modify Security Levels
/usr/bin/sed -i.bak '/^flags/ s/$/,fm/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.18	Audit Attempts to Modify Information Categories
/usr/bin/sed -i.bak '/^flags/ s/$/,fm/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.19	Audit Attempts to Delete Privileges
/usr/bin/sed -i.bak '/^flags/ s/$/,fm/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.20	Audit Attempts to Access Privileges
/usr/bin/sed -i.bak '/^flags/ s/$/,lo,ad,aa/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.21	Set Log File Ownership - ignored

#7.22	Set System Log File Permissions -ignored

#7.23	Set System Log File ACLs -ignored

#7.24	Audit Changes to System Access Restrictions
/usr/bin/sed -i.bak '/^flags/ s/$/,fm,-fr,-fw/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.25	Audit Changes to Audit Settings
/usr/bin/sed -i.bak '/^flags/ s/$/,ad/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.26	Audit Execution of Privileged Functions
/usr/bin/sed -i.bak '/^flags/ s/$/,ad/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

#7.27	Audit Attempts to Modify Privileges
/usr/bin/sed -i.bak '/^flags/ s/$/,lo/' /etc/security/audit_control 2>>/var/log/hardening.log 2>&1

/usr/sbin/audit -s 2>>/var/log/hardening.log 2>&1

#8.1	Enable Security Assessment Policy Subsystem
/usr/sbin/spctl --master-enable 2>>/var/log/hardening.log 2>&1

#8.2	Protect Software Libraries -ignored

#8.3 	Install Configuration Profile - Parallels SCCM

#8.4	Restrict Execution to Authorized Software - Parallels SCCM

#9.1	Ensure Integrity of Applications- Parallels SCCM

#9.2	Protect Gatekeeper Software Validation- Parallels SCCM

#10.1	Disable Unused Network Devices -ignored

#10.2	Set Safari Preferences - Set manually in default Profile

#10.3	Check for Invalid Root Accounts - Set manually in all ICE OSX images

#10.4	Restrict Use of setuid - Set manually in Configuration Profile

#10.5	Automated Vulnerability Scans - Set with McAfee AV

#10.6	Scan for Unauthorized Software - Set with McAfee AV

#Add UserAgent for Safari
# /usr/bin/defaults write /Library/Preferences/com.apple.Safari CustomUserAgent -string "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/538.34.48 (KHTML, like Gecko) Version/8.0 Safari/538.35.8;C15IE72011A"

useragent="Mozilla/5.0 (Macintosh; Intel macOS) AppleWebKit (KHTML, like Gecko);C15IE72011A"
/usr/bin/defaults write /Library/Preferences/com.apple.Safari CustomUserAgent -string "$useragent" 2>>/var/log/hardening.log 2>&1

#NIH Plugin Settings
# /usr/bin/defaults write /Library/Preferences/gov.nih.NIHAuthPlugin ARDExemptionEnabled -bool true
# /usr/bin/defaults write /Library/Preferences/gov.nih.NIHAuthPlugin NoCertExemptionEnabled -bool true
# /usr/bin/defaults write /Library/Preferences/gov.nih.NIHAuthPlugin EnforceOfflineSmartCard -bool true
# /usr/bin/defaults write /Library/Preferences/gov.nih.NIHAuthPlugin GroupExemptionsEnabled -bool true
# /usr/bin/defaults write /Library/Preferences/gov.nih.NIHAuthPlugin GroupExemptions -array "ENT-SG-SecurityScanning" "EntIT-Tier4-ENG" "HQ1-SG-USCIS-SEDMacTesters"
# /usr/bin/defaults write /Library/Preferences/gov.nih.NIHAuthPlugin LogOnlyGroupEnabled -bool false
# /usr/bin/defaults write /Library/Preferences/gov.nih.NIHAuthPlugin LogOnlyGroup -string ""
# /usr/bin/defaults write /Library/Preferences/gov.nih.NIHAuthPlugin WarningGroupEnabled -bool false
# /usr/bin/defaults write /Library/Preferences/gov.nih.NIHAuthPlugin WarningGroup -string ""
# /usr/bin/defaults write /Library/Preferences/gov.nih.NIHAuthPlugin SmartCardSubTitleEnforced -string "USCIS Enforces SmartCard (PIV) Login on all Workstations and Laptops"
# /usr/bin/defaults write /Library/Preferences/gov.nih.NIHAuthPlugin SmartCardSubTitleWarning -string ""
# /usr/bin/defaults write /Library/Preferences/gov.nih.NIHAuthPlugin SmartCardBannerHelpDesk -string "Contact USCIS Service Desk at 1-888-220-5228 for any issues."
# /usr/bin/defaults write /Library/Preferences/gov.nih.NIHAuthPlugin SmartCardBannerDim -bool true

#Disable iCloud Setup Window
/usr/bin/defaults write /Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool true 2>>/var/log/hardening.log 2>&1
/usr/bin/defaults write /Library/Preferences/com.apple.SetupAssistant GestureMovieSeen -string "" 2>>/var/log/hardening.log 2>&1
/usr/bin/defaults write /Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion -string "10.11" 2>>/var/log/hardening.log 2>&1

#Disable smartcard pairing requests.
/usr/bin/defaults write /Library/Preferences/com.apple.security.smartcard UserPairing -bool false 2>>/var/log/hardening.log 2>&1

#Disable ipv6
# /usr/sbin/networksetup -setv6off "Ethernet"
# /usr/sbin/networksetup -setv6off "Wi-Fi"
# /usr/sbin/networksetup -setv6off "Thunderbolt Ethernet"

#Set Proxy? CONFIG PROFILE???
/usr/sbin/networksetup -setautoproxyurl "Wi-Fi" http://pac.uscis.dhs.gov/uscis/proxy.pac 2>>/var/log/hardening.log 2>&1
/usr/sbin/networksetup -setautoproxyurl "Thunderbolt Ethernet" http://pac.uscis.dhs.gov/uscis/proxy.pac 2>>/var/log/hardening.log 2>&1
/usr/sbin/networksetup -setautoproxyurl "Ethernet" http://pac.uscis.dhs.gov/uscis/proxy.pac 2>>/var/log/hardening.log 2>&1
/usr/sbin/networksetup -setautoproxystate "Wi-Fi" on 2>>/var/log/hardening.log 2>&1
/usr/sbin/networksetup -setautoproxystate "Thunderbolt Ethernet" on 2>>/var/log/hardening.log 2>&1
/usr/sbin/networksetup -setautoproxystate "Ethernet" on 2>>/var/log/hardening.log 2>&1
exit 0