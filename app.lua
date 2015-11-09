local local_cache = require "resty.lrucache"
local redis = require "redtool"

local cache = local_cache.new(200)
local servernames = ngx.shared.servernames

if not cache then
    ngx.log(ngx.ERR, "failed to create cache ", err)
    return
end

local function get_from_servernames()
    local value = servernames:get(ngx.var.host)
    if err then
        ngx.log(ngx.ERR, "failed to get backend ", err)
    end
    return value
end

backend, _ = cache:get(ngx.var.host)
if not backend then
    backend = get_from_servernames()
    if not backend then
        ngx.log(ngx.ERR, "no such backend")
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
    -- 600s ttl
    cache:set(ngx.var.host, backend, 600)
end
ngx.var.backend = backend

