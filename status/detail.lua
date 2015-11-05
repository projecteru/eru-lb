local redis = require "redtool"

if not ngx.var.arg_host then
    return ngx.exit(ngx.HTTP_NOT_FOUND)
end

local function calc_status()
    local rds = redis:new()
    local host = ngx.var.arg_host
    local status_key = "loadb:"..host..":status"
    local seconds_key = "loadb:"..host..":time"
    local total_key = "loadb:"..host..":count"

    local total, err = rds:get(total_key)
    if err then
        return nil, nil, nil, err
    end
    local seconds, err = rds:get(seconds_key)
    if err then
        return nil, nil, nil, err
    end
    local status, err = rds:hgetall(status_key)
    if err then
        return nil, nil, nil, err
    end
    return total, seconds, status, nil
end

local total, seconds, status, err = calc_status()
if err then
    ngx.log(ngx.ERR, err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

if not total or not seconds or not status then
    ngx.say("no data")
    return
end

local per_resp = tonumber(seconds) / tonumber(total)

ngx.say("total response: ", total)
ngx.say("per response time: ", per_resp)
for i=1,table.getn(status),2 do
    ngx.say("status ", status[i], " num: ", status[i+1])
end

