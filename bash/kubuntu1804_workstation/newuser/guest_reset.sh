#!/usr/bin/env bash

DIRS_TO_REMOVE=(
    "~/.config/TimeDoctorLLC/TimeDoctorPro.conf"
    "~/.config/Time\ Doctor"
    "~/.config/chromium"
#    "~/.config/opera"
#    "~/.config/opera-beta"
    "~/.Skype"
)

echo "@reboot bash -c 'rm -fr ${DIRS_TO_REMOVE[*]}'" | crontab -
