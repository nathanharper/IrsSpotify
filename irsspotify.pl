use strict;
use utf8;
use vars qw($VERSION %IRSSI);
use Irssi qw(command_bind active_win);
use LWP::UserAgent;
use HTML::Entities;
use JSON;
use DBI;
# TODO: 
# 1. prevent duplicate polling if /irsspotify is called twice.
# 2. save all settings as global vars and update 
#    when a settings change is detected, so we don't need to read settings each time we poll
# 3. make a change to irsspotify_timeout take effect immediately

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
my $DBI_DRIVER = '';
my $DBI_USER = '';
my $DBI_PASSWORD = '';
my $MY_NICK = '';
my $MY_CHAN = '';
my %UID_HASH = ();

# Use this function to initiate
sub irsspotify {
    Irssi::print('Started Irsspotify session');
    $DBI_DRIVER = Irssi::settings_get_str('dbi_source');
    $DBI_USER = Irssi::settings_get_str('dbi_user');
    $DBI_PASSWORD = Irssi::settings_get_str('dbi_password');
    $MY_CHAN = Irssi::settings_get_str('irsspotify_chan');
    $MY_NICK = Irssi::settings_get_str('irsspotify_nick');
    my $timeout = Irssi::settings_get_int('irsspotify_timeout');
    my $timeout_flag = Irssi::timeout_add(($timeout * 1000), 'spotify_poll', '');
}

sub spotify_poll {
    my $port = Irssi::settings_get_int('irsspotify_port');
    my $url = "http://localhost:" . $port;
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

    if ($track->{id} && $track->{id} ne $track_id) {
        $track_id = $track->{id};
        $track_name = $track->{name};
        $track_artist = $track->{artist};
        save_song($track_name, $track_artist, 'spotify', $MY_NICK);

        if (my $chan = Irssi::channel_find($MY_CHAN)) {
            my $to_print = decode_entities($track_artist . ' - ' . $track_name);
            $chan->window->command("/me : $to_print (spotify)");
        }
    }
    else {
        # Irssi::print('old track! not repeating.');
    }

    return $track;
}

sub save_song {
    my ($title, $artist, $service, $nick) = @_;
    if ($DBI_DRIVER && $DBI_USER && $DBI_PASSWORD) {
        my $dbh = DBI->connect($DBI_DRIVER, $DBI_USER, $DBI_PASSWORD)
            or return 0;
        my $user_id = get_user_id($dbh, $nick);
        my $query = "INSERT INTO `play` 
                        (`title`, `artist`, `service`, `user_id`, `created_time`) 
                     VALUES (?, ?, ?, ?, ?)";
        my $sth = $dbh->prepare($query);
        $sth->execute($title, $artist, $service, $user_id, time) 
            or return 0;
        $dbh->disconnect;
    }
    return 1;
}

# Search for the user in the database and create if necessary.
sub get_user_id {
    my ($dbh, $username) = @_;
    if (!$UID_HASH{$username}) {
        my $id = 0;
        my $sth = $dbh->prepare("SELECT `id` FROM `user` WHERE `name` = ?");
        $sth->execute($username) or return 0;
        if (my $result = $sth->fetchrow_hashref()) {
            $id = $result->{id} or 0;
        }
        else {
            $sth = $dbh->prepare("INSERT INTO `user` (`name`) VALUES (?)");
            $sth->execute($username) or return 0;
            $id = $dbh->last_insert_id(undef, undef, undef, undef) or 0; # parameters not necessary for mysql...
        }
        $UID_HASH{$username} = $id;
    }
    return $UID_HASH{$username};
}

# catch messages from other users. Record them if they look like song reports.
sub catch_play {
    my ($server, $msg, $nick, $address, $target) = @_;
    if ($target ne $MY_CHAN || $nick eq $MY_NICK) { return; }
    if ($msg =~ /^\s*(\S.*?)\s-\s+(\S.*?)(?:\s+\((\S.*)\)\s*)?$/) {
        save_song($2, $1, "$3", $nick);
    }
    Irssi::signal_continue($server, $msg, $nick, $address, $target);
}

Irssi::settings_add_int('irsspotify', 'irsspotify_port', 8090);
Irssi::settings_add_int('irsspotify', 'irsspotify_timeout', 20);
Irssi::settings_add_str('irsspotify', 'irsspotify_chan', '#music');
Irssi::settings_add_str('irsspotify', 'irsspotify_nick', 'my_nick');
Irssi::settings_add_str('irsspotify', 'dbi_source', 'dbi:mysql:mysql:localhost');
Irssi::settings_add_str('irsspotify', 'dbi_user', 'root');
Irssi::settings_add_str('irsspotify', 'dbi_password', '');

Irssi::command_bind("irsspotify", \&irsspotify);
Irssi::signal_add('message public', 'catch_play');
