-- Author: Applejuice

local class = require("golf.class")
local pnoise= require("golf/flag/pnoise")

local FlagModel = class("BallModel")


local flagColors = {
    "light_blue", "pink", "white", "pink", "light_blue"
}

function FlagModel:init(flag)
    self.flag = flag

    self.fences = {}
    self.wools = {}
    self.holeId = math.random()
    self.hole = models.tasks:addBlock(self.holeId):block("minecraft:black_concrete")

    for i = 1, 6 do
        local id = math.random()
        table.insert(self.fences, {id = id, part = models.tasks:addBlock(id):block("minecraft:oak_fence")})
    end

    for i = 1, 20 do
        for j = 1, #flagColors do
            local id = math.random()
            table.insert(self.wools, {id = id, w = i, h = j, part = models.tasks:addBlock(id):block("minecraft:" .. flagColors[j] .. "_concrete")})
        end
    end

    self.elevation = 0

    self.offset = math.random() * 100
end

function FlagModel:render(delta)
    for i, v in pairs(self.flag.ballProvider()) do
        if (v.ball.pos - self.flag.pos):length() < 5 then
            self.elevation = self.elevation + 0.2
            break
        end
    end
    self.elevation = self.elevation - 0.1
    self.elevation = math.max(math.min(self.elevation, 3), 0)

    for i, v in ipairs(self.fences) do
        v.part:pos((self.flag.pos + vec(-0.25, i + self.elevation - 1, -0.25)) * 16):scale(0.5, 1, 0.5)
    end

    local orient = pnoise:noise(self.flag.pos.x / 100, self.flag.pos.y / 100, world.getTime(delta) / 500) * 720 / 2
    for i, v in ipairs(self.wools) do
        local time = world.getTime(delta) + math.cos((v.h + world.getTime(delta) / 10) * 2) + self.offset
        local cycle = math.cos((-v.w + time) / 2.5) + math.sin((-v.w + time) / 2.5 - math.pi / 2) * 10
        local rotation = (math.cos(cycle / 5) - 0.5) * ((v.w + 16) / 5)

        v.part:pos((self.flag.pos + vec(0, 4.6 + self.elevation, 0) + vectors.rotateAroundAxis(rotation + orient, vec(v.w / 10, 0, 0), vec(0, 1, 0)) - vec(0.05, 4 / 16 / 2, 0.05)) * 16 + vec(0, v.h * 4 - math.abs(rotation) / 5, 0))
        v.part:scale(0.1, 4 / 16, 0.1)
        v.part:rot(0, 0, 0)
    end

    self.hole:pos((self.flag.pos + vec(-0.125, 0, -0.125) * self.elevation / 3) * 16):scale(vec(0.25, 0.01, 0.25) * self.elevation / 3)

    if self.elevation == 0 or math.random() > 0.9 then
        -- particles["minecraft:totem_of_undying"]:pos(self.flag.pos + vec(math.random() - 0.5, 0, math.random() - 0.5)):gravity(-1 - math.random() / 2):lifetime(640):spawn()
    end
end

function FlagModel:dispose()
    for i, v in ipairs(self.fences) do
        models.tasks:removeTask(v.id)
    end
    for i, v in ipairs(self.wools) do
        models.tasks:removeTask(v.id)
    end
    models.tasks:removeTask(self.holeId)
end

return FlagModel