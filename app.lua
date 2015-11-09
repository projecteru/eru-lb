local local_cache = require "resty.lrucache"

local cache = local_cache.new(200)
local servernames = ngx.shared.servernames

if not cache then
    ngx.log(ngx.ERR, "failed to create cache ", err)
    return
end

local function get_from_servernames()
    local value = servernames:get(ngx.var.host)
    if not value then
        ngx.log(ngx.ERR, "no such backend")
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
    return value
end

backend, _ = cache:get(ngx.var.host)
if not backend then
    backend = get_from_servernames()
    -- 60s ttl
    cache:set(ngx.var.host, backend, 60)
end

ngx.var.backend = backend

