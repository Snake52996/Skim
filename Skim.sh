printHelp() {
    echo "Usage: $0 <video_path> [<row_number> <column_number>]"
    exit 1
}
getDuration() {
    ffmpeg -i "$1" -vcodec copy -acodec copy -f null /dev/null > "$1_helper1" 2>&1
    tac "$1_helper1" | grep "frame=" > "$1_helper"
    rm "$1_helper1"
    local INFO="`cat \"$1_helper\"`"
    local TEMP_INFO=""
    local FRAMES=0
    while true
    do
        INFO=${INFO#*frame=}
        INFO="`eval echo -n $INFO`"
        if [ "$INFO" = "$TEMP_INFO" ]; then
            break
        fi
        TEMP_INFO=${INFO%%" "*}
        TEMP_INFO="`eval echo -n $TEMP_INFO`"
        if [ "$TEMP_INFO" -gt "$FRAMES" ]; then
            FRAMES=$TEMP_INFO
        fi
        TEMP_INFO=$INFO
    done
    rm "$1_helper"
    return $FRAMES
}
getStepLength() {
    local STEP=`expr $2 - 1`
    local STEP_LENGTH=`expr $1 / $STEP`
    return $STEP_LENGTH
}
generateShotcuts() {
    ffmpeg -i "$1" -vf "select=between(n\,0\,$2)*not(mod(n\,$3))" -vsync 0 "$1_temp_%d.jpg" > /dev/null 2>&1
}
combineShotcuts() {
    local R_INDEX=0
    local C_INDEX=1
    local REAL=0
    if [ -f "$1_Preview.jpg" ]; then
        rm "$1_Preview.jpg"
    fi
    while [ $R_INDEX -lt $2 ]
    do
        C_INDEX=1
        while [ $C_INDEX -le $3 ]
        do
            REAL=`expr $R_INDEX \* $3 + $C_INDEX`
            if [ $C_INDEX -eq 1 ]; then
                cp "$1_temp_$REAL.jpg" "$1_temp_ROW_$R_INDEX.jpg"
            else
                convert +append "$1_temp_ROW_$R_INDEX.jpg" "$1_temp_$REAL.jpg" "$1_temp_ROW_$R_INDEX.jpg"
            fi
            C_INDEX=`expr $C_INDEX + 1`
        done
        if [ $R_INDEX -eq 0 ]; then
            cp "$1_temp_ROW_$R_INDEX.jpg" "$1_Preview.jpg"
        else
            convert -append "$1_Preview.jpg" "$1_temp_ROW_$R_INDEX.jpg" "$1_Preview.jpg"
        fi
        R_INDEX=`expr $R_INDEX + 1`
    done
}
cleanUp() {
    rm "$1_temp_"*
}
# >>>> Enterence <<<<
# Verify parameters
if [ $# -ne 1 -a $# -ne 3 ]; then
    printHelp
fi
ROWS=4
COLS=6
if [ $# -eq 3 ]; then
    ROWS=$2
    COLS=$3
fi
PREVIEWS=`expr $ROWS \* $COLS`
getDuration "$1"
FRAMES=$?
getStepLength $FRAMES $PREVIEWS
STEP_LENGTH=$?
generateShotcuts "$1" $FRAMES $STEP_LENGTH
combineShotcuts "$1" $ROWS $COLS
cleanUp "$1"
