#!/usr/bin/env bash

main() {
    while [[ 1 ]]; do
        repeatCommand 2 clickToBottomPanel
        altTab
        sleep 4
        if (( `randomIntBetween 0 10` > 3 )); then
            prevTab
        else
            nextTab
        fi
    done
}

nextTab() {
    if [[ `focusedWindowName` == "Chromium" ]]; then
        ctrlTab
    fi
    if [[ `focusedWindowName` == "PhpStorm" ]]; then
        altRight
    fi
}

prevTab() {
    if [[ `focusedWindowName` == "Chromium" ]]; then
        ctrlShiftTab
    fi
    if [[ `focusedWindowName` == "PhpStorm" ]]; then
        altLeft
    fi
}

randomIntBetween() {
    lowerBound=$1
    upperBound=$2
    shuf -i ${lowerBound}-${upperBound} -n 1
}

focusedWindowName() {
    xdotool getwindowfocus getwindowname | lastWordInLine
}

lastWordInLine() {
    awk 'NF>1{print $NF}'
}

repeatCommand() {
    times="$1"
    command="$2"
    for (( c=0; c<${times}; c++ ))
    do
       ${command}
    done
}

clickToBottomPanel() {
    xdotool mousemove 15 1065 click 1
}

altRight() {
    xdotool keydown alt key Right
    sleep 1
    xdotool keyup alt
}

altLeft() {
    xdotool keydown alt key Left
    sleep 1
    xdotool keyup alt
}

ctrlTab() {
    xdotool keydown ctrl key Tab
    sleep 1
    xdotool keyup ctrl
}

ctrlShiftTab() {
    xdotool keydown ctrl keydown shift key Tab
    sleep 1
    xdotool keyup ctrl
    xdotool keyup shift
}

altTab() {
    xdotool keydown alt key Tab
    sleep 1
    xdotool keyup alt
}

main