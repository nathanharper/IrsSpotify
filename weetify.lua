weechat.register("weetify", 
                 "Nathun", 
                 "1.0", 
                 "Beerware", 
                 "Read and post Spotify plays", 
                 "", 
                 "UTF-8")

local http = require "socket.http"
local json = require "dkjson"
local cat = table.concat
-- local   db = require("luasql.mysql").mysql()

local weetify = {
  track = {}, -- name, artist, id
  port = 8090,
  db = {
    database = '',
    user = '',
    password = ''
  },
  nick = '',
  server = '',
  chan = '',
  users = {} -- id => name
}

function weetify_read_track(track)
  if not track.artist 
     or not track.name 
     or not track.id 
     or track.id == weetify.track.id
  then return false end

  weetify.track.name = track.name
  weetify.track.artist = track.artist
  weetify.track.id = track.id
  return cat{track.artist,' - ',track.name,' (spotify)'}
end

-- local buffer = weechat.buffer_search("irc", weetify.get_chan())
-- local buffer = weechat.info_get("irc_buffer", weetify.get_chan())
function weetify_poll(...)
  weechat.print("", "Polling...")
  local b, c = http.request('http://localhost:' .. weetify.port)
  if c == 200 then
    local resp, _, err = json.decode(b)
    if err then
      return weechat.print("", "JSON decode fail: " .. err)
    end

    local track_str = weetify_read_track(resp)
    if track_str then
      local buffer = ''
      if weetify.server and weetify.chan then
        buffer = cat{weetify.server,',',weetify.chan}
      end
      weechat.command(buffer, "/me " .. track_str)
    end
  else
    weechat.print("", "Weetify HTTP request fail: " .. c)
  end
end

-- function weetify.save_song(song)
--   local conn = assert(db:connect(weetify.db.database,
--                                  weetify.db.user,
--                                  weetify.db.password,
--                                  'http://localhost',
--                                  3306))
--   local res = assert(conn:execute(string.format([[
--     INSERT INTO `play` 
--       (`title`, `artist`, `service`, `user_id`, `created_time`) 
--     VALUES (]] .. 
-- end

weechat.hook_timer(30 * 1000, 30, 0, "weetify_poll", "")
