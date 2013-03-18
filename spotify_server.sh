#!/bin/bash
# Start the node server
tmux new-session -d -s irsspotify 
tmux send-keys -t irsspotify "node ~/Spotify/irsspotify/server.js" C-m
