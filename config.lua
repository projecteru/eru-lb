local _M = {}

_M.REDIS_HOST = os.getenv("REDIS_HOST") or 'localhost'
_M.REDIS_PORT = os.getenv("REDIS_PORT") or '6379'
_M.ELB_NAME = os.getenv('ELB_NAME') or 'ELB-DEV'
_M.BAD_GATEWAY = "502"
_M.ADD_DOMAIN = 'add'
_M.DELETE_DOMAIN = 'delete'
_M.UPDATE_DOMAIN = 'update'
_M.RELOAD = 'reload'

_M.INIT_TYPE = 'init'
_M.MONITOR_TYPE = 'monitor'

return _M
