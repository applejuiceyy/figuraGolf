-- Author: Applejuice

local class = require("golf/class")
local balls = require("golf/ball/main")
local flags = require("golf/flag/main")
local Event = require("golf/events")


local State = class("State")

function State:init()
    self.balls = {}
    self.poles = {}

    self.ballids = {}
    self.poleids = {}

    self.syncpos = 1

    self.updateBalls = Event:new()
    self.updatePoles = Event:new()

    self.focusedBall = nil
end

function State:tick()
    for _, v in pairs(self.balls) do
        v.model:pretick()
        v.ball:tick()
        
        if v.controller ~= nil then
            v.controller:tick()
        end
    end
    for _, v in pairs(self.poles) do
        v.pole:tick()
    end
    if host:isHost() and (world.getTime() % 200 == 0) and ((#self.ballids + #self.poleids) > 0) then
        if self.syncpos > #self.ballids + #self.poleids then
            self.syncpos = 1
        end
        if self.syncpos > #self.ballids then
            local id = self.poleids[self.syncpos - #self.ballids]
            local item = self.poles[id]
            self:NETWORK_syncPole(id, item.pole.pos)
        else
            local id = self.ballids[self.syncpos]
            local item = self.balls[id]
            self:NETWORK_syncBall(id, item.ball.pos, item.ball.vel)
        end
        self.syncpos = self.syncpos + 1
    end
end

function State:render(delta)
    for _, v in pairs(self.balls) do
        v.model:render(delta)
        if host:isHost() then
            v.controller:render(delta)
        end
    end
    for _, v in pairs(self.poles) do
        v.model:render(delta)
    end
end

function State:focusBall(id)
    if self.focusedBall ~= nil then
        self:unfocusBall()
    end
    self.focusedBall = id
    self.balls[id].controller:focus()
end

function State:unfocusBall()
    if self.focusedBall ~= nil then
        self.balls[self.focusedBall].controller:unfocus()
    end
end



function State:NETWORK_createBall(pos)
    pings.createBall(world.getTime(math.random()), pos)
end

function State:NETWORK_deleteBall(id)
    pings.deleteBall(id)
end

function State:NETWORK_createPole(pos)
    pings.createPole(world.getTime(math.random()), pos)
end

function State:NETWORK_deletePole(id)
    pings.deletePole(id)
end

function State:NETWORK_ballPosAndVelocity(id, pos, vel)
    pings.ballPosAndVelocity(id, pos, vel)
end

function State:NETWORK_ballCheckpoint(id, pos)
    pings.ballCheckpoint(id, pos)
end

function State:NETWORK_winBall(pos)
    pings.winBall(pos)
end

function State:NETWORK_syncBall(id, pos, vel)
    pings.syncBall(id, pos, vel)
end

function State:NETWORK_syncPole(id, pos)
    pings.syncPole(id, pos)
end








local state = State:new()

local function _createBall(id, pos, vel)
    local ball = balls.Ball:new(pos)
    ball.vel = vel
    local model = balls.BallModel:new(ball)
    local controller

    if host:isHost() then
        controller = balls.BallController:new(id, ball)
    end

    ball.poleProvider = function()
        return state.poles
    end

    state.balls[id] = {
        ball = ball,
        controller = controller,
        model = model
    }

    table.insert(state.ballids, id)

    state.updateBalls:fire()
end

local function _createPole(id, pos)
    local pole = flags.Flag:new(pos)
    local model = flags.FlagModel:new(pole)

    state.poles[id] = {
        pole = pole,
        model = model
    }

    table.insert(state.poleids, id)
    pole.ballProvider = function()
        return state.balls
    end

    state.updatePoles:fire()
end


function pings.createBall(id, pos)
    _createBall(id, pos, vec(0, 0, 0))
end

function pings.deleteBall(id)
    if state.balls[id] ~= nil then
        state.balls[id].model:dispose()

        if state.balls[id].controller ~= nil then
            state.balls[id].controller:dispose()
        end

        if state.focusedBall == id then
            state.focusedBall = nil
        end

        state.balls[id] = nil

        for i, v in ipairs(state.ballids) do
            if v == id then
                table.remove(state.ballids, i)
                break
            end
        end
        state.updateBalls:fire()
    end
end

function pings.deletePole(id)
    if state.poles[id] ~= nil then
        state.poles[id].model:dispose()
        state.poles[id] = nil

        for i, v in ipairs(state.poleids) do
            if v == id then
                table.remove(state.poleids, i)
                break
            end
        end

        state.updatePoles:fire()
    end
end

function pings.createPole(id, pos)
    _createPole(id, pos)
end

function pings.ballPosAndVelocity(id, pos, vel)
    if state.balls[id] == nil then
        print("WARNING: received ping about unexistent ball")
        _createBall(id, pos, vel)
    else
        state.balls[id].ball.pos = pos
        state.balls[id].ball.vel = vel
    end
end

function pings.ballCheckpoint(id, pos)
    state.balls[id].ball.lastpos = pos
end

function pings.winBall(pos)
    for i = 1, 100 do
        particles["minecraft:totem_of_undying"]:pos(pos):velocity(vec(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 3):spawn()
    end
end

function pings.syncBall(id, pos, vel)
    if host:isHost() then return end

    if state.balls[id] == nil then
        print("WARNING: received ping about unexistent ball")
        _createBall(id, pos, vel)
    else
        state.balls[id].ball.pos = pos
        state.balls[id].ball.vel = vel
    end
end

function pings.syncPole(id, pos)
    if host:isHost() then return end

    if state.poles[id] == nil then
        print("WARNING: received ping about unexistent pole")
        _createPole(id, pos)
    else
        state.poles[id].pole.pos = pos
    end
end

_G.state = state

return state