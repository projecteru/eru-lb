local redis = require "redtool"

if ngx.var.backend == '' then
    return
end

local host = ngx.var.host
local status = ngx.var.upstream_status
local seconds = ngx.var.upstream_response_time

local function calc_status(premature)
    local rds = redis:new()
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
