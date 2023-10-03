#!/bin/sh

cliphist list | wofi -d | cliphist decode | wl-copy
