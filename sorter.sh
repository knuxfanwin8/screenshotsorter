#!/bin/bash

#--------------------#
#  ScreenshotSorter  #
#                    #
#   by knuxfanwin8   #
#--------------------#

usage="sorter.sh (refresh rate in seconds) (screenshot directory)"

# Check if all arguments are supplied
if [ -z "$*" ]; then
    echo "No arguments supplied!"
    echo "Usage: $usage" 
    exit 1
fi

if [ -z "$2" ]; then
    echo "No path supplied!"
    echo "Usage: $usage"
    exit 1
fi

# Assign the arguments to variables
secsleep="$1"
dirpath="$2"

# Display warning if sleep time is 0
if [ "$secsleep" = "0" ]; then
    if [ -x "$(command -v kdialog)" ]; then 
        if ! kdialog --title "Screenshot Sorter" --warningyesno "Using the refresh rate of 0 can be VERY resource intensive! Are you sure you want to continue?"; then exit 0; fi
    elif [ -x "$(command -v zenity)" ]; then 
       if ! zenity --warning --title="Screenshot Sorter" --text="Using the refresh rate of 0 can be VERY resource intensive! Are you sure you want to continue?"; then exit 0; fi
    else
        echo 'WARNING!!!'
        echo 'Using the refresh rate of 0 can be VERY resource intensive! Are you sure you want to continue? [y/N]'
        while ! [ "$choice" = "y" ] || ! [ "$choice" = "n" ] || ! [ "$choice" = "Y" ] || ! [ "$choice" = "N" ]; do
        read -ren1 choice
        if [ -z "$choice" ]; then exit 0; fi
            case $choice in
                "y") break;;
                "n") exit 0;;
                "Y") break;;
                "N") exit 0;;
            esac
        done
    fi
fi

# Check if the directory is valid
if ! [ -e "$dirpath" ]; then
    echo "Screenshot directory does not exist!"
    exit 2
fi

# If the screenshots sub-directory doesn't exist, create it
if ! [ -d "$dirpath/Screenshots" ]; then mkdir "$dirpath/Screenshots"; fi

# TODO: loop through existing screenshots to put them in the directory as well

# Create initial lastcheck file
if ! [ -e "$dirpath/Screenshots/.lastcheck" ]; then touch "$dirpath/Screenshots/.lastcheck"; fi

# The actual loop
while true; do
    # Create a folder for the current date and month, if necesary 
    if ! [ -e "$dirpath/Screenshots/$(date +%Y-%m)" ] 
    then 
        mkdir "$dirpath/Screenshots/$(date +%Y-%m)" 
    fi
    # Get last screenshot number 
    if ! [ -e "$dirpath/Screenshots/.lastnum" ]; then echo "0" > "$dirpath/Screenshots/.lastnum"; fi
    number=$(cat "$dirpath/Screenshots/.lastnum") 
    # Watch for new files
    for file in "$dirpath/"*; do
        if ! [ "$file" = "Screenshots" ] && ! [ -d "$file" ]; then
            # Get file extention
            extention="${file##*.}"
            # Move the file
            if [ "$(find "$file" -cnewer "$dirpath/Screenshots/.lastcheck")" ]; then
                mv "$file" "$dirpath/Screenshots/$(date +%Y-%m)/Screenshot_$number.$extention"
                # Update the last screenshot number
                echo "$((number + 1 ))" > "$dirpath/Screenshots/.lastnum"
                # Show notification (or echo to the command line, depending on command availability)
                if [ -x "$(command -v kdialog)" ]; then 
                    kdialog --title "Screenshot saved!" --passivepopup "Saved as Screenshot_$number.$extention." 3
                elif [ -x "$(command -v zenity)" ]; then 
                    zenity --notification --text="Saved as Screenshot_$number.$extention."
                else
                    echo 'Photo saved.'
                fi
				# Copy to clipboard (requires xclip)
				if [ -x "$(command -v xclip)" ]; then
					xclip -selection clipboard -t image/$extention -i $dirpath/Screenshots/$(date +%Y-%m)/Screenshot_$number.$extention 
				fi
            fi
        fi
    done
    # Update last check file
    touch "$dirpath/Screenshots/.lastcheck"
    # Wait before refresh
    sleep "$secsleep"
done
