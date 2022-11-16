-- Author: Applejuice

local class = require "golf/class"

local FlagWinFirework = class("FlagWinFirework")


local globalSounds = {}

events.TICK:register(function()
    for i = #globalSounds, 1, -1 do
        local sound = globalSounds[i]
        if sound:isPlaying() then
            sound:pos(client.getCameraPos() + vec(0, 10, 0))
        else
            table.remove(globalSounds, i)
        end
    end
end)

function FlagWinFirework:init(pos)
    self.pos = pos
    self.vel = vec(0, math.random() / 0.1 + 0.6, 0)
    self.jerk = vec((math.random() - 0.5) / 20, 0, (math.random() - 0.5) / 20)
    self.tickid = math.random()
    self.ticks = 0
end

function FlagWinFirework:play()
    events.TICK:register(function() self:tickAnimation() end, self.tickid)
end

function FlagWinFirework:tickAnimation()
    self.ticks = self.ticks + 1
    self.vel = self.vel + self.jerk
    self.pos = self.pos + self.vel

    particles:addParticle("minecraft:firework", self.pos)

    if self.ticks > 100 then
        local color = vec(math.random() > 0.5 and 1 or 0, math.random() > 0.5 and 1 or 0, math.random() > 0.5 and 1 or 0)
        for i = 0, 100 do
            particles["minecraft:firework"]:color(color):scale(10, 10, 10):pos(self.pos):velocity(vec(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5):normalize() * 4):spawn()
        end
        table.insert(globalSounds, sounds["entity.firework_rocket.large_blast"]:pos(client.getCameraPos() + vec(0, 10, 0)):play())
        if math.random() > 0.5 then
            table.insert(globalSounds, sounds["entity.firework_rocket.twinkle"]:pos(client.getCameraPos() + vec(0, 10, 0)):play())
        end
        events.TICK:remove(self.tickid)
    end
end

return FlagWinFirework