local dyups = require "ngx.dyups"
local route_table = ngx.shared.routetable

local _M = {}

function _M.update_route_table(route_name, backend_name)
    local ok, err = route_table:add(route_name, backend_name)
    if not ok and err ~= "exists" then
        ngx.log(ngx.ERR, ' error when updating domain ', err)
    end
end

function _M.update_backends(backend_name, backends)
    local backends_table = {}
    for _, backend in pairs(backends) do
        local b = 'server '..backend..';'
        table.insert(backends_table, b)
    end
    local servers = table.concat(backends_table, '\n')
    local status, err = dyups.update(backend_name, servers)
    if status ~= ngx.HTTP_OK then
        ngx.log(ngx.ERR, ' error when updating upstream ', err)
        return
    end
end

function _M.delete_route(route_name, backend_name)
    local route_name = domain..'_'..location
    route_table:delete(route_name)
    local ok, err = dyups.delete(backend_name)
    if ok ~= 200 then
        ngx.log(ngx.ERR, err)
    end
end

return _M
