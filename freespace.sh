#!/bin/bash

# freespacenotifier
#
# Small bash script using notify-send (xfce4) to notify user
# when there is not so much disc space left. Notification is
# displayed ones for 30 minutes (or when new value is exceeded).
#
# licence: GNU GPL
# author: sokoli / sokoli.pl
# github: https://github.com/mplonski/freespacenotifier
#
# how to use it:
# 0) change lockdir / lockfile (or leave it)
# 1) change "sda1" in discinfo (if you're not about to test sda1)
# 2) change title / warning (or leave it)
# 3) add / remove / change code under testspace()
# 4) add this script to crontab and don't worry about disc space!
#
# warning!
# sometimes script seems not to be working after "just" adding to crontab
# in such cases you might need to specify display and enable X ACL
# more: https://help.ubuntu.com/community/CronHowto#GUI%20Applications
#

# uncomment line below in order to enable X ACL for localhost
# xhost +local: &>/dev/null

# readable part
hdiscinfo="`df -h | grep sda1`"
hfreespace="`echo $hdiscinfo | awk '{ print $4 }'`"
hmaxspace="`echo $hdiscinfo | awk '{ print $2 }'`"

# GB-part
discinfo="`df -BG | grep sda1`"
freespace="`echo $discinfo | awk '{ print $4 }'`"
numfreespace="`echo $freespace | sed '{s/[^0-9,]*//g; s/,/./g}'`"
maxspace="`echo $discinfo | awk '{ print $2 }'`"

title="Warning!"
warning="Free disc space is low. Available $hfreespace of $hmaxspace."

lockdir="/var/lock/"
lockfile="freespacelock"

locked() {
	tmplockfile="$lockfile$1"
	if ! test -f $lockdir$tmplockfile
	then
		echo "no"
		touch $lockdir$tmplockfile
	elif test "`find $lockdir -name $tmplockfile -mmin +30`"
	then
		echo "no"
		touch $lockdir$tmplockfile
	else
		echo "yes"
	fi
}

testspace() {
	minspace="$1"
	icon="$2"

	if awk "BEGIN {exit !($minspace >= $numfreespace)}"
	then
		if test "`locked $minspace`" = "no"
		then
			/usr/bin/notify-send "$title" "$warning" --icon=dialog-$icon
			exit
		fi
	fi
}

# to activate notifications you need to add / remove / change code below.
#
# in this example there're:
# a) information for 5GB left
# b) warnings for 3GB & 4GB left
# c) errors for 2GB & 1GB left
#
# remember that df -BG rounds values to full GB.
#
# important: remember to put smaller values first!

testspace "1" "error"
testspace "2" "error"
testspace "3" "warning"
testspace "4" "warning"
testspace "5" "information"

