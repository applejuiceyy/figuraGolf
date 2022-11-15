local class = require "golf.class"
local Event = class("Event")

function Event:init()
    self.subs = {}
end

function Event:register(func, name)
    if name == nil then
        name = {}
    end
    self.subs[name] = func
end

function Event:fire(...)
    for _, v in pairs(self.subs) do
        v(...)
    end
end

function Event:remove(name)
    self.subs[name] = nil
end

return Event