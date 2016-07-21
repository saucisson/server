#! /usr/bin/env lua

local Socket = require "socket"
local Url    = require "socket.url"
local Et     = require "etlua"

do -- Wait for database connection
  local parsed = Url.parse ("http://" .. os.getenv "POSTGRES_HOST")
  local socket = Socket.tcp ()
  local i = 0
  while not socket:connect (parsed.host or "localhost", parsed.port or 5432) do
    if i > 10 then
      error "Database is not reachable."
    end
    os.execute [[ sleep 1 ]]
    i = i+1
  end
end

assert (os.execute (Et.render ([[ <%- prefix %>/bin/lapis migrate ]], {
  prefix = os.getenv "COSY_PREFIX",
})))

assert (os.execute (Et.render ([[ <%- prefix %>/bin/lapis server ]], {
  prefix = os.getenv "COSY_PREFIX",
})))
