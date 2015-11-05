local redis = require "resty.redis"

if ngx.var.backend == '' then
    return
end

local host = ngx.var.host
local status = ngx.var.upstream_status
local seconds = ngx.var.upstream_response_time

local redis_host = ngx.var.redis_host
local redis_port = ngx.var.redis_port

local function calc_status(premature)
    local rds, err = redis:new()
    local ok, err = rds:connect(redis_host, tonumber(redis_port))
    local status_key = "loadb:"..host..":status"
    local seconds_key = "loadb:"..host..":time"
    local total_key = "loadb:"..host..":count"
    rds:hincrby(status_key, status, 1)
    rds:incr(total_key)
    rds:incrbyfloat(seconds_key, tonumber(seconds))
end

local ok, err = ngx.timer.at(0, calc_status)
if not ok then
    ngx.log(ngx.ERR, "failed to create timer: ", err)
    return
end
