local class = require "golf/class"
local Camera = class("Camera")

local currentCamera = nil
local currentPos = client.getCameraPos()
local currentRot = client.getCameraRot()

events.RENDER:register(function(e)
    if currentCamera == nil then
        renderer:setCameraPivot(nil, nil, nil)
        renderer:setCameraRot(nil, nil, nil)

        currentPos = client.getCameraPos()
        currentRot = client.getCameraRot()
    else
        currentPos = math.lerp(currentPos, currentCamera.desiredPos, currentCamera.lerpFinish)

        local newCurrentRot = vec(0, 0, 0)
    
        for i = 1, 3 do
            if math.abs(currentRot[i] - currentCamera.desiredRot[i]) < 0.01 then
                newCurrentRot[i] = currentCamera.desiredRot[i]
            else
                newCurrentRot[i] = math.lerpAngle(currentRot[i], currentCamera.desiredRot[i], currentCamera.lerpFinish)
            end
        end

        currentRot = newCurrentRot
    
        renderer:setCameraPivot(currentPos)
        renderer:setCameraRot(currentRot)
    end
end)


function Camera:init()
    self.lerpFinish = 1

    self.desiredPos = client.getCameraPos()
    self.desiredRot = vec(0, 0, 0)
end

function Camera:lerpFactor(lerp)
    self.lerpFinish = lerp
end

function Camera:towards(pos, rot)
    self.desiredPos = pos
    self.desiredRot = rot
end

function Camera:isActive()
    return currentCamera == self
end

function Camera:setActive()
    currentCamera = self
end

function Camera:unsetActive()
    if self:isActive() then currentCamera = nil end
end

function Camera:getCurrentPos()
    return currentPos:copy()
end

function Camera:getCurrentRot()
    return currentRot:copy()
end

return Camera