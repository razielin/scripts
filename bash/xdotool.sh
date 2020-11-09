#!/usr/bin/env bash

main() {
    sleep 3
    while true; do
        repeatCommand 2 clickToStartMenu
        altTab
        if (( $(randomIntBetween 0 3) > 1 )); then
            pageDown
        else
            pageUp
        fi

        sleep "$(randomIntBetween 3 6)"
        if (( $(randomIntBetween 0 10) > 4 )); then
            prevTab
        else
            nextTab
        fi

        sleep "$(randomIntBetween 1 5)"
        if (( $(randomIntBetween 0 3) > 1 )); then
            pageDown
        else
            pageUp
        fi

        clickOnEmptySpaceOfBottomPanel "$(randomIntBetween 2 20)"
    done
}

nextTab() {
    ctrlTab
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

clickToStartMenu() {
    xdotool mousemove 15 1065 click 1
}

clickOnEmptySpaceOfBottomPanel() {
    times=$1
    xdotool mousemove 900 1065 click 1
    for (( c=0; c<times; c++ )); do
        eval "$(xdotool getmouselocation --shell)"
        # if mouse cursor has been moved - stop clicking
        if [[ $X -eq 900 ]];then
            xdotool click 1
        fi
        sleep 1
    done
}

altRight() {
    xdotool key alt+Right
    sleep 1
}

altLeft() {
    xdotool key alt+Left
    sleep 1
}

ctrlTab() {
    xdotool key ctrl+Tab
    sleep 1
}

ctrlShiftTab() {
    xdotool key ctrl+shift+Tab
    sleep 1
}

altTab() {
    xdotool key alt+Tab
    sleep 1
}

pageUp() {
    xdotool key Page_Up
    sleep 1
}

pageDown() {
    xdotool key Page_Down
    sleep 1
}

main