#!/bin/sh

swaymsg move workspace number $1 && swaymsg workspace number $1
