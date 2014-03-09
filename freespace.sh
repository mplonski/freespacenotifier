#!/bin/bash

# freespacenotifier
#
# small bash script using notify-send (xfce4) to notify user
# when there is not so much disc space left
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

discinfo="`df -h | grep sda1`"
freespace="`echo $discinfo | awk '{ print $4 }'`"
numfreespace="`echo $freespace | sed '{s/[^0-9,]*//g; s/,/./g}'`"
maxspace="`echo $discinfo | awk '{ print $2 }'`"

title="Warning!"
warning="Free disc space is low. Available $freespace of $maxspace."

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

	if awk "BEGIN {exit !($minspace > $numfreespace)}"
	then
		if test "`locked $minspace`" = "no"
		then
			/usr/bin/notify-send "$title" "$warning" --icon=dialog-$icon
			exit
		fi
	fi
}

# to activate warnings you need to add / remove / change code below
# in this example there're warnings for 3GB or 4GB left and errors for 2GB and 1GB left
# remember to put smaller values first!

testspace "1.0" "error"
testspace "2.0" "error"
testspace "3.0" "warning"
testspace "4.0" "warning"

