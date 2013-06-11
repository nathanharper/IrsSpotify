import weechat, json, urllib2

weechat.register(
"weetify", 
"Nathun", 
"1.0", 
"Beerware", 
"Read and post Spotify plays", 
"", 
"UTF-8")

port = '8090'
server = 'reflexions'
chan = '#rJams'
track = {}

def weetify_read_track(new_track):
  try:
    if 'id' in track and track['id'] == new_track['id']:
      weechat.prnt("", "song already reported")
      return False
    track['name'] = new_track['name']
    track['id'] = new_track['id']
    track['artist'] = new_track['artist']
  except KeyError as e:
    weechat.prnt("", "Some key was unset in the track received.")
    return False

  return track['artist'] + ' - ' + track['name'] + ' (spotify)'

def weetify_poll(data, remaining_calls):
  weechat.prnt("", "Polling...")
  try:
    res = urllib2.urlopen('http://localhost:'+port)
    data = res.read()
  except urllib2.URLError as e:
    weechat.prnt("", e.reason)
    return weechat.WEECHAT_RC_ERROR

  try:
    js = json.loads(data)
  except ValueError as e:
    weechat.prnt("", "Invalid JSON.")
    return weechat.WEECHAT_RC_ERROR

  track_str = weetify_read_track(js)
  if not track_str:
    weechat.prnt("", "No new track data.")
    return weechat.WEECHAT_RC_OK

  buffer = weechat.info_get("irc_buffer", server+','+chan)
  weechat.command(buffer, '/me ' + track_str)
  return weechat.WEECHAT_RC_OK

# -- function weetify.save_song(song)
# --   local conn = assert(db:connect(weetify.db.database,
# --                                  weetify.db.user,
# --                                  weetify.db.password,
# --                                  'http://localhost',
# --                                  3306))
# --   local res = assert(conn:execute(string.format([[
# --     INSERT INTO `play` 
# --       (`title`, `artist`, `service`, `user_id`, `created_time`) 
# --     VALUES (]] .. 
# -- end

weechat.hook_timer(30 * 1000, 30, 0, "weetify_poll", "")
