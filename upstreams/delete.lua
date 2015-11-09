if ngx.var.request_method ~= 'DELETE' then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local utils = require "utils"
local data = utils.read_data()

local dyups = require "ngx.dyups"
local backend = data["backend"]
local ok, err = dyups.delete(backend)
if ok ~= 200 then
    ngx.log(ngx.ERR, err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end
ngx.say(cjson.encode({msg = 'ok'}))
return
