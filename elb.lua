local cjson = require "cjson"
local config = require "config"
local redis = require "redtool"
local router = require "router"
local utils = require "utils"
local lock = require "resty.lock"

local _M = {}
local mt = {
    __index = _M
}

function _M.new(self)
    return setmetatable({
        name = config.ELB_NAME,
    }, mt)
end

function _M.update_app_route_table(self, domain, location, backend_name)
    -- 这里需要记住自己现在有哪些域名对应
    -- 哪些新的需要添加进来
    -- 哪些旧的需要删掉
    local route_name = domain..'_'..location
    router.update_route_table(route_name, backend_name)
    ngx.log(ngx.NOTICE, ' update app domain '..domain..' '..location)
end

function _M.delete_app_route_table(self, domain, location, backend_name)
    local route_name = domain..'_'..location
    router.delete_route(route_name, backend_name)
    ngx.log(ngx.NOTICE, ' delete app domain '..domain..' '..location)
end

function _M.update_app_backends(self, backend_name, backends)
    -- 这里直接全部重新设置就可以了
    router.update_backends(backend_name, backends)
    ngx.log(ngx.NOTICE, ' update app backends '..backend_name)
end

function _M.load_route_table(self)
    local mutex = lock:new("analysis", {timeout=0, exptime=3})
    local es, err = mutex:lock(config.INIT_TYPE)
    if not es then
        ngx.log(ngx.NOTICE, ' ELB init in another worker ')
        return
    end
    local key = self.name..':info'
    local rds = redis:new()
    local info = rds:get(key)
    if not info then
        ngx.log(ngx.ERR, ' ELB get none info ')
        return
    end
    local data = cjson.decode(info)
    for _, d in pairs(data) do
        -- 先抓对应的后端, 更新 upstream
        local backend_name = d['appname']..'_'..d['version']..'_'..d['entrypoint']..'_'..d['pod']
        if self:load_app_nodes(backend_name) then
            -- 再更新对应的域名和 upstream 的名字
            self:update_app_route_table(d['domain'], d['location'], backend_name)
        end
    end
    -- automatic released
    -- mutex:unlock()
end

function _M.load_app_nodes(self, backend_name)
    local rds = redis:new()
    local backends = rds:lrange(backend_name, 0, 01)
    if not backends then
        ngx.log(ngx.ERR, ' ELB get none app backends '..backend_name)
        return false
    end

    self:update_app_backends(backend_name, backends)
    return true
end

function _M.monitor(self)
    local mutex = lock:new("analysis", {timeout=0, exptime=3})
    local es, err = mutex:lock(config.MONITOR_TYPE)
    if not es then
        ngx.log(ngx.NOTICE, ' ELB start monitor in another worker ')
        return
    end
    local key = self.name..':update'
    local rds = redis:new()
    local update = rds:subscribe(key)
    if not update then
        ngx.log(ngx.ERR, ' ELB start monitor failed ')
        return
    end
    ngx.log(ngx.NOTICE, ' ELB start monitor ')
    while true do
        if ngx.worker.exiting() then
            break
        end
        local res, err = update()
        if err and err ~= 'timeout' then
            ngx.log(ngx.ERR, ' ELB disconnect from redis '..err)
            -- 重新 subscribe
            -- 重载路由表
            update = nil
            while not update do
                update = rds:subscribe(key)
            end
            self:load_route_table()
        elseif res ~= nil and res[1] == 'message' then
            local msg = res[3]
            ngx.log(ngx.NOTICE, ' ELB get message '.. msg)
            local data = cjson.decode(msg)
            local ctrl = data['control']
            local meta = data['data']
            ngx.log(ngx.NOTICE, ctrl..' app '..meta['appname'])

            if ctrl ~= config.RELOAD then
                local backend_name = meta['appname']..'_'..meta['version']..'_'..meta['entrypoint']..'_'..meta['pod']
                if ctrl == config.ADD_DOMAIN then
                    -- 先抓对应的后端, 更新 upstream
                    if self:load_app_nodes(backend_name) then
                        -- 再更新对应的域名和 upstream 的名字
                        self:update_app_route_table(meta['domain'], meta['location'], backend_name)
                    end
                elseif ctrl == config.DELETE_DOMAIN then
                    self:delete_app_route_table(meta['domain'], meta['location'], backend_name)
                elseif ctrl == config.UPDATE_DOMAIN then
                    self:load_app_nodes(backend_name)
                end
            else
                self:load_route_table()
            end
        end
    end
    -- automatic released
    -- mutex:unlock()
end

return _M
