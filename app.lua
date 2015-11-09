local local_cache = require "resty.lrucache"
local utils = require "utils"

local cache = local_cache.new(200)
if not cache then
    ngx.log(ngx.ERR, "failed to create cache ", err)
    return
end

backend, _ = cache:get(ngx.var.host)
if not backend then
    backend = utils.get_from_servernames(ngx.var.host)
    -- 60s ttl
    cache:set(ngx.var.host, backend, 60)
end

ngx.var.backend = backend

