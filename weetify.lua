local http = require "socket.http"
local json = require "dkjson"
-- local   db = require("luasql.mysql").mysql()
weechat.register("weetify", "Nathun", "1.0", "Beerware", "Read and post Spotify plays", "", "UTF-8")

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

function weetify.poll()
  local b, c = http.request('http://localhost:' .. weetify.port)
  if c == 200 then
    local resp, _, err = json.decode(b)
    if err then
      weechat.print("", "JSON decode fail: " .. err)
    else
      -- local buffer = weechat.buffer_search("irc", weetify.get_chan())
      local buffer = weechat.info_get("irc_buffer", table.concat{weetify.server,',',weetify.chan})
      local track_str = weetify.read_track(resp)
      if track_str then
        weechat.command(buffer, "/me " .. track_str)
        -- weetify.save_song(resp)
      end
    end
  else
    weechat.print("", "Weetify HTTP request fail: " .. c)
  end
end

function weetify.get_chan()
  return table.concat(weetify.server, '.', weetify.chan)
end

function weetify.read_track(track)
  if not track.artist or not track.name or not track.id then
    return false
  end
  weetify.track.name = track.name
  weetify.track.artist = track.artist
  weetify.track.id = track.id
  return track.artist .. ' - ' .. track.name .. ' (spotify)'
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

function weetify.set_port(port)
  weetify.port = port
end
