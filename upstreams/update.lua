if ngx.var.request_method ~= 'PUT' then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local utils = require "utils"
local data = utils.read_data()

local dyups = require "ngx.dyups"
local backend = data["backend"]
local servers = table.concat(data["servers"])
local ok, err = dyups.update(backend, servers)
if ok ~= 200 then
    ngx.log(ngx.ERR, err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end
ngx.say(cjson.encode({msg = 'ok'}))
return
