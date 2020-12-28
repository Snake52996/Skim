dealWithFiles() {
    for file in "$1"/*
    do
        if [ ! -f "$file" ]; then
            continue
        fi
        MIME=`file -ib "$file"`
        TMIME=${MIME#*video}
        if [ "$TMIME" = "$MIME" ]; then
            continue
        fi
        if [ -f "$file""_Preview.jpg" ]; then
            continue
        fi
        echo $file
        ./Skim.sh "$file"
    done
}
dealWithDir() {
    echo "Enter $1/"
    for file in "$1"/*
    do
        if [ -d "$file" ]; then
            dealWithDir "$file"
        fi
    done
    dealWithFiles "$1"
    echo "Exit $1/"
}
dealWithDir "$1"
