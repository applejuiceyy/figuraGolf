local class = require "golf/class"
local collision = require "golf/collision"

local Flag = class("Flag")

function Flag:init(pos)
    self.pos = pos

    self.ballProvider = function() return {} end
end

function Flag:tick()
    if host:isHost() and self:isInLoadedChunks() then
        for i = 1, 100 do
            if collision.collidesWithWorld(self.pos.xyzxyz + vec(-0.1, 0, -0.1, 0.1, 0.01, 0.1)) then
                self.pos.y = self.pos.y + 0.01
            elseif not collision.collidesWithWorld(self.pos.xyzxyz + vec(-0.1, -0.01, -0.1, 0.1, 0, 0.1)) then
                self.pos.y = self.pos.y - 0.01
            else
                break
            end
        end
    end
end

function Flag:isInLoadedChunks(pos)
    return world.getBlockState(pos or self.pos).id ~= "minecraft:void_air"
end


return Flag