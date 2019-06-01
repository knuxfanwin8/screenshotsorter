#!/bin/bash -x
usage="sorter.sh (refresh rate in seconds) (screenshot directory)"

[[ -z "$1" ]] && echo "Usage: $usage" / exit 1
[[ -z "$2" ]] && echo "Usage: $usage" / exit 2
sleep="$1"
rawdir="$2"
screenpath="$rawdir/Screenshots"

command -v zenity &>/dev/null && gui="zenity"
command -v kdialog &>/dev/null && gui="kdialog"

warn() {
	echo "Warning: $*"
	[[ "$gui" ]] && {
		case $gui in
			kdialog) kdialog --title "Warning" --error "$*";;
			zenity) zenity --warning --title="Warning" --text="$*";;
		esac
	}
}

notify() {
	echo "Notification: $*"
	[[ "$gui" ]] && {
		case $gui in
			kdialog) kdialog --title "Screenshot saved" --passivepopup="$*";;
			zenity) zenity --notification --text="$*";;
		esac
	}
}

[[ "$sleep" == 0 ]] && {
	warn "Using the refresh rate of 0 seconds is too resource intensive. Exiting."
	exit 4
}

[[ ! -d "$rawdir" ]] && {
	warn "Screenshot directory doesn't exist, or is a file."/
	exit 2
}

[[ ! -d "$screenpath" ]] && mkdir "$screenpath"
[[ ! -e "$screenpath/.lastcheck" ]] && touch "$screenpath/.lastcheck"

while true; do
	date="$(date +%Y-%m)"
	[[ ! -e "$screenpath/$date" ]] && mkdir "$screenpath/$date"
	number="$(find $screenpath -type f -printf '%T@ %p\n' | sort -n | cut -f2- -d' ' | grep '_' | tail -n1 | cut -f2 -d'_' | cut -f1 -d'.')"
	[[ -z "$number" ]] && number="0"
	for file in "$rawdir/"*; do
		[[ ! -d "$file" ]] && [[ "$(find $file -cnewer $screenpath/.lastcheck)" ]] && {
			(( number++ ))
			extention="${file##*.}"
			mv "$file" "$screenpath/$date/Screenshot_$number.$extention"
			xclip -selection clipboard -t "image/$extention" "$screenpath/$date/Screenshot_$number.$extention"
			notify "Screenshot saved as Screenshot_$number.$extention." &
		}
	done
	touch "$screenpath/.lastcheck"
	sleep "$sleep"
done
