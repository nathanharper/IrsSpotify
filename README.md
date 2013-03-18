A little Spotify app that broadcasts my current track to Irssi. And possibly more, if I feel like it. Instructions for setting up on Mac and Linux:

Get the dependenciez (obviously this assumes you have perl's cpanm and node's npm package installers):

<pre>
cpanm LWP JSON
npm install socket.io
</pre>

Make the spotify dir if it doesn't already exist, and checkout the project.

<pre>
mkdir ~/Spotify
cd ~/Spotify
git clone https://github.com/nathanharper/IrsSpotify.git irsspotify
cd irsspotify
</pre>

Then you have to start the node server with the port you want to use (default is 8090):

<pre>node server.js 8080</pre>

...and then open Spotify with the app running. On a mac this is:

<pre>/Applications/Spotify.app/Contents/MacOS/Spotify spotify:app:irsspotify</pre>

...and on linux (Ubuntu 12.10 at least) it's just this:

<pre>spotify spotify:app:irsspotify</pre>

Now link the perl script to your irssi scripts...

<pre>
cd ~/.irssi/scripts/
ln -s ~/Spotify/irsspotify/irsspotify.pl .
</pre>

Boot up Irssi and run the following commands. Here you can set the default port, channel, and the number of seconds to wait between each song poll. Make sure that the port number you give Irssi matches the one you started the node server with! Default port is 8090, default channel is '#music', and default poll timeout is 20 seconds.

<pre>
/script load irsspotify
/set irsspotify_port 8080
/set irsspotify_chan #music
/set irsspotify_timeout 30
/irsspotify
</pre>

That's it! Now you just have to automate the boot process ;)
