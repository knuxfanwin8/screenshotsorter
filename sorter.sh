#!/bin/bash

#--------------------#
#  ScreenshotSorter  #
#                    #
#   by knuxfanwin8   #
#--------------------#

usage="sorter.sh (refresh rate in seconds) (screenshot directory)"

# Check if all variables are supplied
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

dirpath="$2"
secsleep="$1"

# Check if the directory is valid

if ! [ -e "$dirpath" ]; then
    echo "Screenshot directory does not exist!"
    exit 2
fi

# If screenshots directory doesn't exist, create it
if ! [ -d "$dirpath/Screenshots" ]; then mkdir "$dirpath/Screenshots"; fi

# TODO: loop through existing screenshots to put them in the directory as well
# For now we just move the files to a different directory so that the script doesn't go rampage on them
if ! [ -d "$dirpath/oldImages" ]; then 
    mkdir "$dirpath/oldImages"
    for tomove in "$dirpath/"*; do
        if ! [ "$tomove" = "Screenshots" ] && ! [ "$tomove" = "oldImages" ]; then
            mv "$tomove" "$dirpath/oldImages"
        fi
    done
fi


# The actual loop
if ! [ -e "$dirpath/lastcheck" ]; then touch "$dirpath/lastcheck"; fi
while true; do
    # Create a folder for the current date and month, if necesary /
    if ! [ -e "$dirpath/Screenshots/$(date +%Y-%m)" ] 
    then 
        mkdir "$dirpath/Screenshots/$(date +%Y-%m)" 
    fi
    # Get last screenshot number /
    if ! [ -e "$dirpath/Screenshots/.lastnum" ]; then echo "0" > "$dirpath/Screenshots/.lastnum"; fi
    number=$(cat "$dirpath/Screenshots/.lastnum") 
    # Watch for new files
    for file in "$dirpath/"*; do
        if ! [ "$file" = "Screenshots" ] && ! [ -d "$file" ]; then
                # Get file extention
                extention="${file##*.}"
                # Move the file
                find "$file" -cnewer "$dirpath/lastcheck" -exec bash -c "mv ""$file"" ""$dirpath/Screenshots/$(date +%Y-%m)/Screenshot_$number.$extention"" && echo ""$((number + 1 ))"" > ""$dirpath/Screenshots/.lastnum"" && echo 'Photo saved.'"-- {} \;
        fi
    done
    touch "$dirpath/lastcheck"
    sleep "$secsleep"
done
