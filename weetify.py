import weechat, json, urllib2

weechat.register(
"weetify", 
"Nathun", 
"1.0", 
"Beerware", 
"Read and post Spotify plays", 
"", 
"UTF-8")

track = {}
options = {
  "port" : "8090",
  "server" : "freenode",
  "chan" : "#music"
}

for option, default_value in options.items():
  if not weechat.config_is_set_plugin(option):
    weechat.config_set_plugin(option, default_value)
  else:
    options[option] = weechat.config_string(weechat.config_get("plugins.var.python.weetify." + option))

def config_cb(data, option, value):
  "stash options when the config changes."
  options[option] = value
  return weechat.WEECHAT_RC_OK

def weetify_read_track(new_track):
  "Get the track string, or return False if no new track is detected."
  try:
    if 'id' in track and track['id'] == new_track['id']:
      return False
    track['name'] = new_track['name']
    track['id'] = new_track['id']
    track['artist'] = new_track['artist']
  except KeyError as e:
    return False

  return track['artist'] + ' - ' + track['name'] + ' (spotify)'

def weetify_poll(data, remaining_calls):
  "Poll the server and post the track if one is found."
  try:
    res = urllib2.urlopen('http://localhost:'+options[port])
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
    return weechat.WEECHAT_RC_OK

  buffer = weechat.info_get("irc_buffer", options[server]+','+options[chan])
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
weechat.hook_config("plugins.var.python.weetify.*", "config_cb", "")
