#!/bin/sh

rbw get $(rbw list | wofi -d) | wtype -
