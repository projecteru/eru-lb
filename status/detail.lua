local redis = require "redtool"
local utils = require "utils"

if not ngx.var.arg_host then
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

local function calc_status(host)
    local rds = redis:new()
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
    result["status"] = {}
    for i=1,#status,2 do
        result["status"][status[i]] = status[i + 1]
    end
    result["total"] = tonumber(total)
    result["seconds"] = tonumber(seconds)
    result["wrong"] = tonumber(wrong) and tonumber(wrong) or 0
    result["right"] = tonumber(right) and tonumber(right) or 0

    result["per_resp_time"] = result["seconds"] / result["right"]
    result["error_percent"] = result["wrong"] / result["total"]
    result["right_percent"] = result["right"] / result["total"]
    return result, nil
end

local host = ngx.var.arg_host
utils.get_from_servernames(host)

local result, err = calc_status(host)
if err then
    ngx.log(ngx.ERR, err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

ngx.say(cjson.encode(result))
