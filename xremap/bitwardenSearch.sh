#!/bin/env fish

rbw get $(rbw list | wofi -d) | wtype -
