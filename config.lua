local _M = {}

_M.REDIS_HOST = os.getenv("REDIS_HOST")
_M.REDIS_PORT = os.getenv("REDIS_PORT")
_M.BAD_GATEWAY = "502"

return _M
