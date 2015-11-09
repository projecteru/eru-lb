local concat = table.concat
local upstream = require "ngx.upstream"
local get_servers = upstream.get_servers
local get_upstreams = upstream.get_upstreams

local us = get_upstreams()
local result = {}
for _, u in ipairs(us) do
    local srvs, err = get_servers(u)
    if not srvs then
        ngx.say("failed to get servers in upstream ", u)
    else
        result[u] = srvs
    end
end
ngx.say(cjson.encode(result))
