local redis = require "redtool"
local upstream = require "ngx.upstream"
local config = require "config"

local host = ngx.var.host
if ngx.var.backend == "" then
    ngx.log(ngx.ERR, "invalid domain: ", host)
    return
end

local _, err = upstream.get_servers(ngx.var.backend)
local status = config.BAD_GATEWAY
local seconds = 0.0
if err then
    ngx.log(ngx.ERR, "no backend: ", host)
else
    status = ngx.var.upstream_status
    seconds = tonumber(ngx.var.upstream_response_time)
end

local function calc_status(premature)
    local rds = redis:new()
    local status_key = "loadb:"..host..":status"
    local seconds_key = "loadb:"..host..":time"
    local total_key = "loadb:"..host..":count"
    local wrong_key = "loadb:"..host..":wrong"
    local right_key = "loadb:"..host..":right"
    rds:incr(total_key)
    rds:hincrby(status_key, status, 1)
    if tonumber(status) > 399 then
        rds:incr(wrong_key)
    else
        rds:incr(right_key)
    end
    rds:incrbyfloat(seconds_key, seconds)
end

local ok, err = ngx.timer.at(0, calc_status)
if not ok then
    ngx.log(ngx.ERR, "failed to create timer: ", err)
    return
end
