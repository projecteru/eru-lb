local utils = require "utils"
local dyups = require "ngx.dyups"

local function update()
    local data = utils.read_data()
    local backend = data["backend"]
    if not backend then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    local servers = table.concat(data["servers"])
    local ok, err = dyups.update(backend, servers)
    if ok ~= 200 then
        ngx.log(ngx.ERR, err)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    ngx.say(cjson.encode({msg = 'ok'}))
    ngx.exit(ngx.HTTP_OK)
end

local function delete()
    local data = utils.read_data()
    local backend = data["backend"]
    if not backend then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    local ok, err = dyups.delete(backend)
    if ok ~= 200 then
        ngx.log(ngx.ERR, err)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    ngx.say(cjson.encode({msg = 'ok'}))
    ngx.exit(ngx.HTTP_OK)
end

local function detail()
    local upstream = require "ngx.upstream"
    local get_servers = upstream.get_servers
    local get_upstreams = upstream.get_upstreams
    local us = get_upstreams()
    local result = {}
    for _, u in ipairs(us) do
        local srvs, err = get_servers(u)
        if not srvs then
            ngx.log(ngx.ERR, "failed to get servers in upstream ", u)
        else
            result[u] = srvs
        end
    end
    ngx.say(cjson.encode(result))
end

if ngx.var.request_method == 'PUT' then
    update()
elseif ngx.var.request_method == 'DELETE' then
    delete()
elseif ngx.var.request_method == 'GET' then
    detail()
end
ngx.exit(ngx.HTTP_BAD_REQUEST)

