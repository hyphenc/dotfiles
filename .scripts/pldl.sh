#!/bin/bash
#expects that there's a delimiter, else it asks you
#uses gnu sed and jq
#was originally intended for playlists, i added a single video download function a while back, i don't know if it actually works™
#why dont u youtube-dl --embed-thumbnail with atomicparsley? bc i dont want another package, and tbh i dont care about the time it takes, since it runs in the bg :)
set -eo pipefail
DIR="$HOME/Music/$3" #without slash at the end!

setData() {
    vtitle=$(youtube-dl -e "$1")
    artist=$(sed 's/ [-\—\–\‒\:\~\-].*//' <<< "$vtitle")
    title=$(sed "s/$artist [-\—\–\‒\:\~\-]* //" <<< "$vtitle" | sed 's/ - .*$//' | sed 's/ [(\\[\||\\/\/\|\+\~\-\(0-9.{4})].*$//' | sed "s/^[\"\']//" | sed "s/[\"\']$//" | sed 's/\[a-zA-Z0-9].{3}//')
    if [[ ! $(grep -P " [-\—\–\‒\:\~\-].*" <<< "$vtitle") ]]; then
        echo "Couldn't auto-extract for '"$vtitle"', please provide the data yourself."
        read -rp "artist? : " artist
        read -rp "title?  : " title
    fi
}

fetchPlaylist() {
    items=($(youtube-dl --quiet -j --flat-playlist "$1" | jq -r ".id" | sed 's_^_https://youtube.com/watch?v=_'))
}

prepDownload() {
    for ((i=0; i<${#items[@]}; i++)) ; do
        if [[ ! $(grep ${items[$i]} "$DIR"/musicdownloaded.txt) ]]; then
            setData "${items[$i]}"
            echo -ne "($(( $i + 1 ))/${#items[@]}) Downloading '$vtitle'"
            downloadAndEncode "${items[$i]}" "$artist" "$title"
            echo "$(date '+%D %T') -- ${items[$i]} -- $artist - $title" >> "$DIR"/musicdownloaded.txt
        else
            echo "Skipping, already downloaded."
        fi
    done
}

downloadAndEncode() {
    youtube-dl --quiet --write-thumbnail --skip-download -cwi -o /tmp/musicdl-cover "$1"
    youtube-dl --download-archive "$DIR"/downloaded.txt --quiet -f bestaudio "$1" -cwi -o - | ffmpeg -hide_banner -loglevel panic -i - /tmp/musicdl-aud.mp3 -preset ultrafast
    ffmpeg -hide_banner -loglevel panic -i /tmp/musicdl-aud.mp3 -i /tmp/musicdl-cover.jpg -c copy -map 0 -map 1 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (Front)" -metadata title="$3" -metadata artist="$2" "$DIR"/"$2 - $3".mp3 -preset ultrafast
    echo -e "\nDownloaded to '"$DIR"/"$2 - $3".mp3'\n"
    rm /tmp/musicdl*
}
    if [[ ! -d "$DIR" ]]; then mkdir -p "$DIR"; fi
    if [[ ! -f "$DIR"/musicdownloaded.txt ]]; then touch "$DIR"/musicdownloaded.txt; fi

case $1 in
    -p)
        if [ -z "$3" ]; then echo -ne "./pldl.sh -p <link to playlist> <dir>\n" && exit 1; fi
        fetchPlaylist "$2"
        prepDownload;;
    -v)
        if [ -z "$3" ]; then echo -ne "./pldl.sh -v <link to video> <dir>\n" && exit 1; fi
        items=("$2")
        prepDownload;;
    *)
      echo -ne "./pldl.sh -p <link to playlist> ~/Music/<dir>\n-v for a single video, dunno if that actually works™";;
esac
