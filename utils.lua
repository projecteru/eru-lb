local _M = {}

function _M.read_data()
    ngx.req.read_body()
    local data = cjson.decode(ngx.req.get_body_data())
    if not data then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    return data
end

return _M
