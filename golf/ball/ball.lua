-- Author: Applejuice

local class     = require("golf.class")
local collision = require("golf/collision")
local Event     = require("golf/events")
local settings  = require("golf/settings")

local Ball = class("Ball")

function getFluid(block, y)
    local fluids = block:getFluidTags()
    if #fluids > 0 then
        if block.properties == nil or block.properties == nil or tonumber(block.properties.level) == nil or block.properties.level == "8" or y < (1 - tonumber(block.properties.level) / 8) then
            return fluids
        end
    end
    return {}
end


function Ball:init(pos)
    self.vel = vec(0, 0, 0)
    self.pos = pos
    self:checkpoint()

    self.death = Event:new()
    self.hit = Event:new()
    self.win = Event:new()

    self.inLoadedChunks = true

    self.poleProvider = function() return {} end
end

function Ball:checkpoint()
    self.lastpos = self.pos:copy()
end

function includes(t, v)
    for _, k in pairs(t) do if k == v then return true end end return false
end

local friction = settings.extraSlippery and 0.995 or 0.9
local bouncyness = settings.extraBouncy and -0.9 or -0.4


function Ball:tick()
    self.inLoadedChunks = true
    if not self:isInLoadedChunks() then self.inLoadedChunks = false return end
    local precision = math.floor(self.vel:length() * 2 + 1)
    for i = 1, precision do
        local vel = self.vel:copy()
        vel.y = vel.y - 0.1 / precision

        if not self:isInLoadedChunks(self.pos + vel / precision) then
            self.inLoadedChunks = false
            break
        end

        self.vel.y = self.vel.y - 0.1 / precision

        self.pos.x = self.pos.x + (self.vel.x / precision)

        local block = collision.collidesWithWorld(self.pos.xyzxyz + self:collisionBox())
        if block then
            self.hit:fire(self.pos, self.vel.x, block)
            self.pos.x = self.pos.x - (vel.x / precision)
            vel.x = vel.x * bouncyness
            vel = vel * friction
        end


        self.pos.y = self.pos.y + (self.vel.y / precision)

        local block = collision.collidesWithWorld(self.pos.xyzxyz + self:collisionBox())
        if block then
            self.hit:fire(self.pos, self.vel.y, block)
            self.pos.y = self.pos.y - (self.vel.y / precision)
            vel.y = vel.y * bouncyness
            if math.abs(vel.y) < 0.1 then
                vel.y = 0
            end
            vel = vel * friction
        end


        self.pos.z = self.pos.z + (self.vel.z / precision)

        local block = collision.collidesWithWorld(self.pos.xyzxyz + self:collisionBox())
        if block then
            self.hit:fire(self.pos, self.vel.z, block)
            self.pos.z = self.pos.z - (self.vel.z / precision)
            vel.z = vel.z * bouncyness
            vel = vel * friction
        end

        self.vel = vel
    end

    for i, v in pairs(self.poleProvider()) do
        if collision.collidesWithRectangle(self.pos.xyzxyz + self:collisionBox(), v.pole.pos.xyzxyz + vec(-0.1, 0, -0.1, 0.1, 0.1, 0.1)) then
            self.win:fire(i, v)
        end
    end

    local block = world.getBlockState(self.pos)
    local fluid = getFluid(block, self.pos.y - math.floor(self.pos.y))

    if includes(fluid, "c:water") or includes(fluid, "c:lava")  then
        self.death:fire()
        self.pos = self.lastpos
        self.vel = vec(0, 0, 0)
    end

    if self.pos.y < -100 then
        self.death:fire()
        self.pos = self.lastpos
        self.vel = vec(0, 0, 0)
    end

    if collision.collidesWithWorld( self.pos.xyzxyz + self:collisionBox()) then
        self.pos.y = self.pos.y + 0.01
    end
end

function Ball:isInLoadedChunks(pos)
    return world.getBlockState(pos or self.pos).id ~= "minecraft:void_air" or (pos or self.pos).y >= 319
end

function Ball:collisionBox()
    return vec(-1 / 16, -1 / 16, -1 / 16, 1 / 16, 1 / 16, 1 / 16)
end








return Ball