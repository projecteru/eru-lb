local utils = require "utils"
local servernames = ngx.shared.servernames

local function add()
    local data = utils.read_data()
    local succ, err, _ = servernames:add(data["name"], data["backend"])
    if not succ then
        ngx.say(cjson.encode({msg = err}))
        if err ~= "exists" then
            ngx.exit(ngx.HTTP_BAD_REQUEST)
        end
        ngx.exit(ngx.HTTP_OK)
    else
        ngx.say(cjson.encode({msg = 'ok'}))
        ngx.exit(ngx.HTTP_OK)
    end
end

local function delete()
    local data = utils.read_data()
    servernames:delete(data["name"])
    -- TODO check err
    -- TODO clean lrucache
    ngx.say(cjson.encode({msg = 'ok'}))
    ngx.exit(ngx.HTTP_OK)
end

local function get()
    local result = {}
    local keys = servernames:get_keys(0)
    for _, domain in ipairs(keys) do
        result[domain] = servernames:get(domain)
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

