if ngx.var.request_method ~= 'DELETE' then
    return ngx.exit(ngx.HTTP_BAD_REQUEST)
end

ngx.req.read_body()
local data = cjson.decode(ngx.req.get_body_data())
if not data then
    return ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local dyups = require "ngx.dyups"
local backend = data["backend"]
local ok, err = dyups.delete(backend)
if ok ~= 200 then
    ngx.log(ngx.ERR, err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end
ngx.say(cjson.encode({msg = 'ok'}))
return
