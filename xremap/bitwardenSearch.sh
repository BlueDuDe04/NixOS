#!/bin/env fish

rbw get $(rbw unlock; rbw list | wofi -d) | tr -d '\n' | wtype -
