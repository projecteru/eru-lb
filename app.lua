local utils = require "utils"

local key = ngx.var.host..'_/'
local default = key
if ngx.var.uri ~= "/" then
    local prefix = utils.split(ngx.var.uri, "/", 2)[2]
    key = key..prefix
end

local backend, _ = cache:get(key)
if not backend then
    backend = utils.get_from_route_table(key) or utils.get_from_route_table(default)
    if not backend then
        ngx.log(ngx.ERR, "no such backend")
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
    -- 60s ttl
    cache:set(key, backend, 60)
end

ngx.var.backend = backend

