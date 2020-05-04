#!/usr/bin/env bash

if [ -p /dev/stdin ]; then
        NB_LINE=0
        while IFS= read line; do
            echo $line
            ((NB_LINE=NB_LINE+1))
        done
        if (($NB_LINE != 2)); then
            exit 1
        else
            exit 0
        fi
else
        echo "No input was found on stdin"
        exit 2
fi