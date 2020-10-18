#!/usr/bin/env bash

#Check For youtube-dl & ProxyChains existence
if [[ -z $(which youtube-dl) || -z $(which proxychains) ]]; then
    zenity --info --width 300 --text "youtube-dl and/or proxychains are not installed."
    exit 0
fi

#Get URL & Checks For Integrity
get_url=$(zenity --entry --width 300 --text "Enter Video url")
if [[ -z $get_url ]]; then
    zenity --info --width 300 --text "Given URL Does not Exist."
    exit 0
else
    url=$get_url
fi

#Defaults
fast_mode=0
vpn_mode=0
cd ~/Videos

#checks For Fast Mode
zenity --question --width 300 --text "Use Fast Mode?"
if [[ $? == 0 ]]; then
    fast_mode=1
fi

#Checks for Youtube Filtering
zenity --question --width 300 --text "Is Youtube Filtered? (Use ProxyChains)"
if [[ $? == 0 ]]; then
    vpn_mode=1
fi

function quality_lister {
    INPUT=~/Desktop/qualities.csv
    OLDIFS=$IFS
    IFS=" "
    selected_quality=$(while read Number Quality Content Size;do
    echo -e "$Number     $Quality     $Content     $Size"
    done <$INPUT|zenity --list --width 700 --height 400 --text "Choose Desired Quality" --column "Available Qualities")
    numb=$(echo $selected_quality | awk {'print$1'})
}

#Main App
if [[ $fast_mode == 1 ]]; then
    if [[ $vpn_mode == 1 ]]; then
        proxychains youtube-dl --write-sub --embed-subs --sub-lang en_US,en-US,en $url | zenity --progress --auto-close --pulsate --no-cancel --text "Downloading..."
    else
        youtube-dl --write-sub --embed-subs --sub-lang en_US,en-US,en $url | zenity --progress --auto-close --pulsate --no-cancel --text "Downloading..."
    fi
else
    if [[ $vpn_mode == 1 ]]; then
        proxychains youtube-dl -F $url | grep mp4 > ~/Desktop/qualities.csv #Delete grep mp4 to download other formats
        quality_lister
        proxychains youtube-dl --write-sub --embed-subs --sub-lang en_US,en-US,en -f $numb $url | zenity --progress --auto-close --pulsate --no-cancel --text "Downloading..."
    else
        youtube-dl -F $url | grep mp4 > ~/Desktop/qualities.csv #Delete grep mp4 to download other formats
        quality_lister
        youtube-dl --write-sub --embed-subs --sub-lang en_US,en-US,en -f $numb $url | zenity --progress --auto-close --pulsate --no-cancel --text "Downloading..."
    fi
fi

#Finalizing
rm $INPUT
if [[ $vpn_mode == 1 ]]; then
    file_name=$(proxychains youtube-dl --get-filename $url | sed -n '2,$p')
else
    file_name=$(youtube-dl --get-filename $url | sed -n '2,$p')
fi

if [[ -z ~/Downloads/Video/$file_name ]]; then
    zenity --info --width 300 --text "Failed To Download The Video."
else
    zenity --info --width 300 --text "Video Downloaded Successfully. It's Located in ~/Videos/$file_name"
fi
