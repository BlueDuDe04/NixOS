#!/bin/env fish

rbw get $(rbw list | wofi -d) | tr -d '\n' | wtype -
