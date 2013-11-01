#!/bin/bash

url=https://pushover.net/api

if type open >/dev/null 2>&1 ; then
    command=open
elif type browser >/dev/null 2>&1 ; then
    command=browser
elif type firefox >/dev/null 2>&1 ; then
    command=firefox
else
    echo "open your browser to https://pushover.net/api"
fi

$command $url
