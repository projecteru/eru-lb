local _M = {}

local analysis = ngx.shared.analysis
local route_table = ngx.shared.routetable

function _M.split(str, sSeparator, nMax, bRegexp)
    assert(sSeparator ~= '')
    assert(nMax == nil or nMax >= 1)

    local aRecord = {}

    if str:len() > 0 then
        local bPlain = not bRegexp
        nMax = nMax or -1

        local nField=1 nStart=1
        local nFirst,nLast = str:find(sSeparator, nStart, bPlain)
        while nFirst and nMax ~= 0 do
            aRecord[nField] = str:sub(nStart, nFirst-1)
            nField = nField+1
            nStart = nLast+1
            nFirst,nLast = str:find(sSeparator, nStart, bPlain)
            nMax = nMax-1
        end
        aRecord[nField] = str:sub(nStart)
    end

    return aRecord
end

function _M.read_data()
    ngx.req.read_body()
    local data = cjson.decode(ngx.req.get_body_data())
    if not data then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end
    return data
end

function _M.get_from_route_table(key)
    local value = route_table:get(key)
    return value
end

function _M.check_if_analysis(host)
    local value = analysis:get(host)
    if not value then
        return false
    end
    return true
end

return _M
