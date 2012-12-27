#!/bin/bash

# This script starts everything you need to track Spotify plays to IRC.
# Should start the node server and establish a connection with Spotify.
# Only thing left to do after this is issue "/irsspotify" command in Irssi.

# Start the node server
tmux new-session -d -s irsspotify 
tmux send-keys -t irsspotify "node ~/Spotify/irsspotify/server.js" C-m

# Start the Spotify binary with the custom app preloaded
tmux split-window -t irsspotify -v -p50
tmux send-keys -t irsspotify "/Applications/Spotify.app/Contents/MacOS/Spotify spotify:app:irssi" C-m
