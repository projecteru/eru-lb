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
    local wrong_key = "loadb:"..host..":wrong"
    local right_key = "loadb:"..host..":right"
    local result = {}

    local total, err = rds:get(total_key)
    if err or not total then
        return nil, err
    end
    local seconds, err = rds:get(seconds_key)
    if err or not seconds then
        return nil, err
    end
    local status, err = rds:hgetall(status_key)
    if err or not status then
        return nil, err
    end
    local right, err = rds:get(right_key)
    if err then
        return nil, err
    end
    local wrong, err = rds:get(wrong_key)
    if err then
        return nil, err
    end
    result["status"] = status
    result["total"] = tonumber(total)
    result["seconds"] = tonumber(seconds)
    result["wrong"] = tonumber(wrong) and tonumber(wrong) or 0
    result["right"] = tonumber(right) and tonumber(right) or 0
    return result, nil
end

local result, err = calc_status()
if err then
    ngx.log(ngx.ERR, err)
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local per_resp_time = result["seconds"] / result["right"]
local error_percent = result["wrong"] / result["total"]
local right_percent = result["right"] / result["total"]

ngx.say("total response: ", result["total"])
ngx.say("error response: ", result["wrong"])
ngx.say("right response: ", result["right"])
ngx.say("error percent: ", error_percent)
ngx.say("right percent: ", right_percent)
ngx.say("right avg response time: ", per_resp_time)
for i=1,table.getn(result["status"]),2 do
    ngx.say("status ", result["status"][i], " num: ", result["status"][i+1])
end
