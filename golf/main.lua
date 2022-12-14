-- Author: Applejuice

local state = require("golf/state")


events.ENTITY_INIT:register(function()
    models.tasks:setLight(15)
    models.tasks:setParentType("World")
end)

events.TICK:register(function()
    state:tick()
end)

events.WORLD_RENDER:register(function(delta)
    state:render(delta)
end)

local lightLevelMaintained = {}

events.TICK:register(function()
    if #lightLevelMaintained > 0 then
        for i = 0, 5 do
            local task = table.remove(lightLevelMaintained, 1)
            task:light(world.getBlockLightLevel(task:getPos() / 16), world.getSkyLightLevel(task:getPos() / 16))
            if #lightLevelMaintained == 0 then break end
        end
    else
        for _, v in pairs(models.tasks:getTask()) do
            table.insert(lightLevelMaintained, v)
        end
    end
end)