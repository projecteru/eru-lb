local elb = require 'elb'

lb = elb:new()
if lb == nil then
    ngx.log(ngx.ERR, ' init elb failed ')
    return
end

local ok, err = ngx.timer.at(0, function()
    lb:load_route_table()
end)
if not ok then
    ngx.log(ngx.ERR, ' load domain error ', err)
    return
end

local ok, err = ngx.timer.at(0, function()
    lb:monitor()
end)
if not ok then
    ngx.log(ngx.ERR, ' monitor failed ', err)
    return
end
