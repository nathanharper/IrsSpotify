use strict;
use vars qw($VERSION %IRSSI);
use Irssi qw(command_bind active_win);
use LWP::UserAgent;
use JSON;
use utf8;

$VERSION = '0.3';

%IRSSI =
(
    authors     => 'Nathan Harper',
    contact     => 'nathan@reflexionsdata.com',
    name        => 'spotify now playing',
    description => 'polls spotify for current track',
    license     => 'iunno',
    url         => 'https://github.com/nathanharper/IrsSpotify',
    changed     => 'Fri Aug 29 16:46:47 IST 2008',
    commands    => 'irsspotify',
);

# store the last track so we don't repeat ourselves
my $track_name = '';
my $track_artist = '';
my $track_id = '';

sub irsspotify {
    Irssi::print('Started Irsspotify session');
    my $timeout_flag = Irssi::timeout_add((20 * 1000), 'spotify_poll', '');
}

sub spotify_poll {
    my $url = "http://localhost:8090";
    my $agent = LWP::UserAgent->new();
    $agent->agent('spotify script');

    $agent->timeout(60);
    
    my $request = HTTP::Request->new(GET => $url);
    my $result = $agent->request($request);

    $result->is_success or return;

    my $track = $result->content;
    if (length($track) > 0) {
        $track = decode_json $track;
    }

    if ($track->{'id'} ne $track_id) {
        $track_id = $track->{'id'};
        $track_name = $track->{'name'};
        $track_artist = $track->{'artist'};
        $track_name =~ s/\s-\s.*$//g; # not foolproof, but this usually strips out any "remaster" crap

        if (my $chan = Irssi::channel_find('#rJams')) {
            my $to_print = $track_artist . ' - ' . $track_name;
            $to_print=~s/&quot;?|&ldquo;?|&rdquo;?/"/g;
            $to_print=~s/&rsquo;?|&lsquo;?|&apos;?/'/g;
            $to_print=~s/&amp;?/&/g;

            $chan->window->command("/me : $to_print");
        }
    }
    else {
        # Irssi::print('old track! not repeating.');
    }

    return $track;
}

Irssi::command_bind("irsspotify", \&irsspotify);
