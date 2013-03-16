A little Spotify app that broadcasts my current track to Irssi. And possibly more, if I feel like it. Instructions for setting up on Mac and Linux:

Make the spotify dir if it doesn't already exist, and checkout the project.

<pre>
mkdir ~/Spotify
cd ~/Spotify
git clone https://github.com/nathanharper/IrsSpotify.git irsspotify
cd irsspotify
</pre>

Then you have to start the node server:

<pre>node server.js</pre>

...and then open Spotify with the app running. On a mac this is:

<pre>/Applications/Spotify.app/Contents/MacOS/Spotify spotify:app:irsspotify</pre>

...and on linux (Ubuntu 12.10 at least) it's just this:

<pre>spotify spotify:app:irsspotify</pre>

Now link the perl script to your irssi scripts...

<pre>
cd ~/.irssi/scripts/
ln -s ~/Spotify/irsspotify/irsspotify.pl .
</pre>

Boot up Irssi and run the following commands:

<pre>
/script load irsspotify
/irsspotify
</pre>

That's it! Now you just have to automate the boot process ;)
