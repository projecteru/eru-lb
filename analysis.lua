local utils = require "utils"
local analysis = ngx.shared.analysis

local function add()
    local data = utils.read_data()
    local result = {}
    local hosts = data['hosts']
    if not hosts then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    for i = 1, #hosts do
        local succ, err, _ = analysis:add(hosts[i], 1)
        if not succ then
            result[hosts[i]] = err
        else
            result[hosts[i]] = 'ok'
        end
    end
    ngx.say(cjson.encode(result))
    ngx.exit(ngx.HTTP_OK)
end

local function delete()
    local data = utils.read_data()
    analysis:delete(data["host"])
    -- TODO check err
    ngx.say(cjson.encode({msg = 'ok'}))
    ngx.exit(ngx.HTTP_OK)
end

local function get()
    local result = {}
    local keys = analysis:get_keys(0)
    for _, domain in ipairs(keys) do
        result[domain] = analysis:get(domain)
    end
    ngx.say(cjson.encode(result))
    ngx.exit(ngx.HTTP_OK)
end

if ngx.var.request_method == 'PUT' then
    add()
elseif ngx.var.request_method == 'DELETE' then
    delete()
elseif ngx.var.request_method == 'GET' then
    get()
end
ngx.exit(ngx.HTTP_BAD_REQUEST)

