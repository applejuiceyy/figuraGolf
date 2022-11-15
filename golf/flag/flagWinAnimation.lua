local class = require "golf/class"
local Camera = require "golf/camera"
local flagWinFireworks = require "golf/flag/flagWinFireworks"
local keybinds         = require "golf/keybinds"
local settings         = require "golf/settings"

local FlagWinning = class("FlagWinning")

function FlagWinning:init(pos)
    self.pos = pos
    self.tickid = math.random()
    self.camera = Camera:new()
    self.camera:lerpFactor(0.03)
    self.ticks = 0
end

function FlagWinning:play()
    if settings.winningCutscene or settings.winningFireworks then
        if settings.winningCutscene then
            self.camera:setActive()
        end
        events.TICK:register(function() self:tickAnimation() end, self.tickid)
    end
end

function FlagWinning:tickAnimation()
    if self.ticks == 5 and settings.winningCutscene then
        keybinds.overriding = true
    end
    self.ticks = self.ticks + 1
    if self.ticks < 500 then
        local t = 500 - (200000 / (self.ticks + 400))
        self.camera:towards(
            self.pos + vectors.rotateAroundAxis(t * 3, vec(t / 2, t / 3.5, 0), vec(0, 1, 0)),
            vec(-self.ticks / 7.5 * (settings.winningFireworks and 1 or -0.7), -t * 3 + 90, 0)
        )
    end

    if math.random() < self.ticks / 2000 and settings.winningFireworks then
        flagWinFireworks:new(self.pos):play()
        for i = 1, 4 do
            particles["minecraft:dust 0.8 0.8 0.8 2"]:pos(self.pos):velocity((math.random() - 0.5) / 100, 0.1, (math.random() - 0.5) / 100):spawn()
        end
    end

    if self.ticks == 550 then
        self.camera:unsetActive()
        keybinds.overriding = false
    end

    if self.ticks > 1000 then
        events.TICK:remove(self.tickid)

    end
end

return FlagWinning