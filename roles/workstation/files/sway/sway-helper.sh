#!/bin/sh

set -e

if [ -e $HOME/.profile ]; then
	. $HOME/.profile
fi

if [ -e $HOME/.config/timezone ]; then
	. $HOME/.config/timezone
fi

sway $@ 2>1 | logger -t sway
