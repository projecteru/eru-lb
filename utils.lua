local _M = {}

local servernames = ngx.shared.servernames

function _M.read_data()
    ngx.req.read_body()
    local data = cjson.decode(ngx.req.get_body_data())
    if not data then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    return data
end

function _M.get_from_servernames(host)
    local value = servernames:get(host)
    if not value then
        ngx.log(ngx.ERR, "no such backend")
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
    return value
end

return _M
