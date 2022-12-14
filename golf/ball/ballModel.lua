-- Author: Applejuice

local class = require("golf.class")

local BallModel = class("BallModel")

function BallModel:init(ball, model)
    self.ball = ball
    self.model = model

    self.oldpos = ball.pos

    self.ballTaskId = math.random()
    self.ballScale = vec(2 / 16, 2 / 16, 2 / 16)
    self.ballTask = models.tasks:newBlock(self.ballTaskId):block("white_wool")

    self.ball.hit:register(function(pos, vel, block)
        for i = 1, math.pow(self.ball.vel:length(), 2) do
            particles["minecraft:block " .. block.id]:scale(self.ball.vel:length() + 1):pos(pos):spawn()
        end
    end)
end

function BallModel:pretick()
    self.oldpos = self.ball.pos:copy()
end

function BallModel:render(delta)
    self.ballTask:pos(math.lerp(self.oldpos, self.ball.pos, delta) * 16 - vec(1, 1, 1))
    local s = math.max((client:getCameraPos() - self.ball.pos):length() - 10, 0) / 5 + 1
    self.ballTask:scale(vec(s, s, s) * self.ballScale)
end

function BallModel:dispose()
    models.tasks:removeTask(self.ballTaskId)
end

return BallModel