local class = require("golf.class")
local Camera = require("golf/camera")
local keybinds = require("golf/keybinds")
local Ball = require("golf/ball/ball")
local settings = require("golf/settings")
local flagWinAnimation = require("golf/flag/flagWinAnimation")
local BallController = class("BallController")

-- view modes
function BallController:secondPersonController()
    return 0.3, self.ball.pos + vectors.rotateAroundAxis(self.yaw, vec(-2, 3, 0), vec(0, 1, 0)), vec(40, -self.yaw - 90, 0)
end

function BallController:toppedController()
    return 0.3, self.ball.pos + vectors.rotateAroundAxis(self.yaw, vec(-2, 1, 0), vec(0, 1, 0)), vec(-20, -self.yaw - 90, 0)
end

function BallController:forwardsController()
    return 0.3, self.ball.pos + vectors.rotateAroundAxis(self.yaw, vec(2, 3, 0) * self.force * 2.5, vec(0, 1, 0)), vec(0, -self.yaw - 90, 0)
end

function BallController:adaptativeCamera()
    local pos, rot
    local average = vec(0, 0, 0)

    local divisor = 0
    local ppos = self.ball.pos
    local range = 3
    for x = -range, range do
        for y = -range, range do
            for z = -range, range do
                local p = vec(x, y, z)
                local strength = (range + 1) - math.max(math.abs(x), math.abs(y), math.abs(z))
                local state = world.getBlockState(ppos + p)
                if not (state:isOpaque() or state:isFullCube()) then
                    -- particles:addParticle("minecraft:dust 1 1 1 " .. strength, ppos + p)
                    average = average + (vec(x, y, z) / strength)
                end
                divisor = divisor + strength
            end
        end
    end

    average = (average / divisor)
    average = average
    average = average:normalize()
    average = average * vec(1, 0.05, 1)
    average = average:normalize() * 5

    pos = average + ppos
    local rotationanchor = math.lerp(self.camera:getCurrentPos(), pos, 0.5)
    if rotationanchor:length() > 0.2 then
        rotationanchor = self.camera:getCurrentPos()
    end

    local l = rotationanchor - ppos
    
    local v = ppos - rotationanchor;
    local g = math.sqrt(math.pow(v.x, 2) + math.pow(v.z, 2));

    local pitch = (((-(math.atan2(v.y, g) * 57.2957763671875))));
    local yaw = (((math.atan2(v.z, v.x) * 57.2957763671875) - 90.0));

    rot = vec(pitch, yaw, 0)

    return math.min((self.camera:getCurrentPos() - self.ball.pos):length() / 1000, 1) + 0.01, pos, rot
end




-- code
function BallController:init(ballid, ball)
    self.ballid = ballid
    self.state = require("golf/state")

    self.ball = ball
    self.controlsTimeout = 10

    self.prediction = {}
    self.predictionBall = nil

    self.viewmode = 1
    self.maxforce = settings.maxforce

    --input

    -- degrees
    self.yaw = 0
    -- degrees
    self.force = 1

    self.camera = Camera:new()

    self.ball.win:register(function()
        self.state:NETWORK_deleteBall(self.ballid)
        self.state:NETWORK_winBall(self.ball.pos)

        flagWinAnimation:new(self.ball.pos):play()
    end)
end

function BallController:focus()
    self.camera:setActive()
    keybinds.overriding = true
    keybinds.unpressAll()
end

function BallController:unfocus()
    self.camera:unsetActive()
    keybinds.overriding = false
    keybinds.unpressAll()
end

function BallController:dispose()
    self:unfocus()
end





function BallController:flushPrediction()
    self.prediction = {}
    self.predictionBall = Ball:new(self.ball.pos:copy())
    self.predictionBall.vel = self:generateVelocityWithCurrentProperties()
    for i = 1, 10 do
        table.insert(self.prediction, self.predictionBall.pos:copy())
        self.predictionBall:tick()
    end
end

function BallController:generateVelocityWithCurrentProperties()
    return vectors.rotateAroundAxis(self.yaw, vectors.rotateAroundAxis(45, vec(self.force, 0, 0), vec(0, 0, 1)), vec(0, 1, 0))
end

function BallController:tick()
    local isInLoadedChunks = self.ball.inLoadedChunks

    if not isInLoadedChunks and self.wasInLoadedChunks then
        logJson('[{"text": "Your ball has gone out of chunks at ", "color": "#994411"}, {"text": "' .. self.ball.pos.x .. ', ' .. self.ball.pos.y .. ', ' .. self.ball.pos.z .. ' ", "color": "#997711"}]')
    end

    if self.ball.vel:length() < 0.01 then
        self.controlsTimeout = self.controlsTimeout - 1

        if self.controlsTimeout == 0 then
            self.state:NETWORK_ballPosAndVelocity(self.ballid, self.ball.pos, settings.extraSlippery and vec(0, 0, 0) or self.ball.vel)
            self:flushPrediction()
        end
    else
        self.controlsTimeout = 10
    end

    if self.controlsTimeout < 0 then
        if self.camera:isActive() then
            local shouldFlush = false
            local step = keybinds.Ctrl:isPressed() and 5 or (keybinds.Shift:isPressed() and 0.1 or 1)
            if keybinds.A:isPressed() then
                self.yaw = self.yaw + step
                shouldFlush = true
            end

            if keybinds.D:isPressed() then
                self.yaw = self.yaw - step
                shouldFlush = true
            end

            if keybinds.W:isPressed() then
                self.force = self.force + 0.1 * step
                self.force = math.min(self.force, self.maxforce)
                shouldFlush = true
            end

            if keybinds.S:isPressed() then
                self.force = self.force - 0.1 * step
                self.force = math.max(self.force, 0)
                shouldFlush = true
            end

            if keybinds.F5:wasPressed() then
                self.viewmode = self.viewmode + 1
                if self.viewmode > #self.viewModes then
                    self.viewmode = 1
                end
            end


            if shouldFlush then
                self:flushPrediction()
            end

            if keybinds.Space:isPressed() then
                local vel = self:generateVelocityWithCurrentProperties()
                self.predictionBall = nil
                self.state:NETWORK_ballCheckpoint(self.ballid, self.ball.pos)
                self.state:NETWORK_ballPosAndVelocity(self.ballid, self.ball.pos, vel)
                self.controlsTimeout = 10
                self.lastBallPos = self.ball.pos:copy()
            end
        end


        if self.predictionBall ~= nil and settings.predictEntirePath then
            table.insert(self.prediction, self.predictionBall.pos:copy())
            self.predictionBall:tick()

            if self.predictionBall.vel:length() < 0.001 then
                self.predictionBall = nil
            end
        end
    end

    keybinds.unpressAll()
    self.wasInLoadedChunks = isInLoadedChunks
end

function BallController:render(delta)
    local radius = math.max(math.min((self.controlsTimeout - delta) / -5, 1), 0)
    if radius > 0 then
        for i = 0, 10 do
            particles["minecraft:totem_of_undying"]:physics(false):lifetime(5):gravity(0):scale(0.5, 0.5, 0.5):velocity(0, 0.1, 0):pos(self.ball.pos + vectors.rotateAroundAxis(i / 10 * 360 + world.getTime(delta), vec(radius, 0, 0), vec(0, 1, 0))):spawn()
        end
        local perc = self.force / self.maxforce
        for i = 0, perc, 0.01 do
            particles["minecraft:dust 1 0 0 1"]:physics(false):lifetime(5):gravity(0):scale(0.5, 0.5, 0.5):velocity(0, 0.1, 0):pos(self.ball.pos + vectors.rotateAroundAxis(i * 360 + self.yaw, vec(radius, 0, 0), vec(0, 1, 0))):spawn()
        end
    end
    if self.controlsTimeout < 0 then
        for i = 1, #self.prediction - 1 do
            particles:addParticle("minecraft:dust 1 0 0 0.3", math.lerp(self.prediction[i], self.prediction[i + 1], world.getTime(delta) % 10 / 10))
        end
    end
    self:updateCameraPosition()
end

function BallController:updateCameraPosition()
    local lerp, pos, rot
    if self.controlsTimeout > 0 then
        lerp, pos, rot = self:adaptativeCamera()
    else
        lerp, pos, rot = self.viewModes[self.viewmode](self)
    end
    self.camera:lerpFactor(lerp)
    self.camera:towards(pos, rot)
end

BallController.viewModes = {
    BallController.secondPersonController,
    BallController.toppedController,
    BallController.forwardsController,
    BallController.adaptativeCamera
}

return BallController