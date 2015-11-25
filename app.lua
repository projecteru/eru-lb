local utils = require "utils"

backend, _ = cache:get(ngx.var.host)
if not backend then
    backend = utils.get_from_servernames(ngx.var.host)
    -- 60s ttl
    cache:set(ngx.var.host, backend, 60)
end

ngx.var.backend = backend

