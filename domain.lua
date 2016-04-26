local route_table = ngx.shared.routetable

local function get()
    local result = {}
    local keys = route_table:get_keys(0)
    for _, domain in ipairs(keys) do
        result[domain] = route_table:get(domain)
    end
    ngx.say(cjson.encode(result))
    ngx.exit(ngx.HTTP_OK)
end

get()
