local Config = require "lapis.config".get ()
local Model  = require "cosy.server.model"
local Http   = require "cosy.server.http"
local Qless  = require "resty.qless"
local Mime   = require "mime"

local Clean = {}

function Clean.create ()
  local qless = Qless.new (Config.redis)
  local queue = qless.queues ["cosy"]
  queue:recur ("cosy.server.jobs.clean", {}, Config.clean.delay, {
    jid = "cosy.server.jobs.clean",
  })
end

function Clean.perform ()
  local services = Model.services:select (([[
    where id not in ( select service_id as id from resources  where service_id is not null
                union select service_id as id from executions where service_id is not null)
    and qless_job is not null
  ]]):gsub ("%s+", " "))
  for _, service in ipairs (services or {}) do
    if service.docker_url then
      local _, status = Http.json {
        url     = service.docker_url,
        method  = "DELETE",
        headers = {
          ["Authorization"] = "Basic " .. Mime.b64 (Config.docker.username .. ":" .. Config.docker.api_key),
        },
      }
      if status >= 200 and status < 300 then
        service:delete ()
      end
    end
  end
end

return Clean
