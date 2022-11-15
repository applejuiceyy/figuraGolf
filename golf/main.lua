local balls = require("golf/ball/main")
local flags = require("golf/flag/main")
local state = require("golf/state")


events.ENTITY_INIT:register(function()
    models.tasks:setParentType("World")
end)

events.TICK:register(function()
    state:tick()
end)

events.RENDER:register(function(delta)
    state:render(delta)
end)