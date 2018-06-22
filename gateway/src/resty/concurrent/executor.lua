--- @module resty.concurrent

--- @type Executor
local _M = {
    default = require('resty.concurrent.immediate_executor')
}

--- @function from_options
--- @static
--- @tparam ?table options
--- @tparam nil|table|string|Executor options.executor
function _M.from_options(options)
    local executor = options and options.executor or nil

    if type(executor) == 'string' then
        return _M[executor] or error('unknown executor: ' .. executor)
    elseif executor then
        return executor
    else
        return _M.default
    end
end


return _M
