#!/bin/sh

cliphist list | sed -n 2p | cliphist decode | wtype -
