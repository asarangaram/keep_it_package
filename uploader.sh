#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 </path/to/your/folder> <Collection Name>"
    exit 1
fi



folder_path="$1"
collection_label="$2"

echo $collection_label

url="http://192.168.1.222:5000/media"

for file in "$folder_path"/*; do
    if [ -f "$file" ]; then

        filename=$(basename "$file")

        echo "uploading $filename"
        mime_type=$(file --mime-type -b "$file")
        
        echo curl -v  -F "media=@${file};type=${mime_type}" -F "collectionLabel=random"  "$url"
        time curl -v  -F "media=@${file};type=${mime_type}" -F "collectionLabel=$collection_label"  "$url"

        sleep 1

    fi
done
