return function (name)
    local obj = setmetatable({}, {})
    obj.__index = obj
    obj.init = function() end

    function obj:new(...)
        local obj = setmetatable({}, self)
        obj:init(...)
        return obj
    end

    return obj
end