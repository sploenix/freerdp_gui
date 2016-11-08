#!/bin/bash

[ -n "TEXTMODE" ] && {
  Red='\e[0;31m'
  BRed='\e[1;31m'
  Green='\e[0;32m'
  BGreen='\e[1;32m'
  Brown='\e[0;33m'
  Yellow='\e[1;33m'
  Blue='\e[0;34m'
  BBlue='\e[1;34m'
  Lila='\e[0;35m'
  BLila='\e[1;35m'
  Cyan='\e[0;36m'
  BCyan='\e[1;36m'
  Grey='\e[0;37m'
  White='\e[1;37m'

  COff='\e[0m'
} || {
  Red=''
  BRed=''
  Green=''
  BGreen=''
  Brown=''
  Yellow=''
  Blue=''
  BBlue=''
  Lila=''
  BLila=''
  Cyan=''
  BCyan=''
  Grey=''
  White=''

  COff=''
}

MAIN_MSG_COLOR="$Lila"
OK_MSG_COLOR="$Green"
FAIL_MSG_COLOR="$Red"
INFO_MSG_COLOR="$Blue"
