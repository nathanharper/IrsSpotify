use strict;
use vars qw($VERSION %IRSSI);
use Irssi qw(command_bind active_win);
use LWP::UserAgent;
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

my $current_track = ''; # store the last track so we don't repeat ourselves

sub irsspotify {
    my $timeout_flag = Irssi::timeout_add((10 * 1000), 'spotify_poll', ''); # 10 seconds
}

sub spotify_poll {
    my $url = "http://localhost:8090";
    my $agent = LWP::UserAgent->new();
    $agent->agent('spotify script');

    $agent->timeout(60);
    
    my $request = HTTP::Request->new(GET => $url);
    my $result = $agent->request($request);

    $result->is_success or return;

    my $str = $result->content;

    if (length($str) > 0 && $str ne $current_track) {
        $current_track = $str;
        foreach my $chan (Irssi::channels())
        {
            if('#rJams' eq $chan->{'name'})
            {
                $str=~s/&quot;?|&ldquo;?|&rdquo;?/"/g;
                $str=~s/&rsquo;?|&lsquo;?|&apos;?/'/g;
                $chan->window->command("/me : $str");
            }
        }
    }
    else {
        # Irssi::print('old track! not repeating.');
    }

    return $str;
}

Irssi::command_bind("irsspotify", \&irsspotify);

