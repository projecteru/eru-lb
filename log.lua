local utils = require "utils"
local redis = require "redtool"
local config = require "config"
local upstream = require "ngx.upstream"

if ngx.var.backend == "" then
    ngx.log(ngx.ERR, "invalid domain: ", ngx.var.host)
    return
end

local host = ngx.var.host
local status = tonumber(ngx.var.upstream_status)
local cost = tonumber(ngx.var.upstream_response_time)

local function calc_status(premature)
    if not utils.check_if_analysis(host) then
        return
    end
    local rds = redis:new()
    local status_key = "erulb:"..host..":status"
    local cost_key = "erulb:"..host..":cost"
    local total_key = "erulb:"..host..":count"
    local miss_key = "erulb:"..host..":miss"
    local hit_key = "erulb:"..host..":hit"
    local wrong_key = "erulb:"..host..":wrong"
    local right_key = "erulb:"..host..":right"

    rds:incr(total_key)
    if not status then
        rds:incr(miss_key)
        ngx.log(ngx.ERR, host, ' ', status, ' ', cost)
        return
    end

    rds:incr(hit_key)
    rds:hincrby(status_key, status, 1)
    if tonumber(status) > 499 then
        rds:incr(wrong_key)
    else
        rds:incr(right_key)
    end
    rds:incrbyfloat(cost_key, cost)
end

local ok, err = ngx.timer.at(0, calc_status)
if not ok then
    ngx.log(ngx.ERR, "failed to create timer: ", err)
    return
end
