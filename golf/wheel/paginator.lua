local class = require("golf/class")

local Paginator = class("Paginator")


function reset(action)
    action:toggled(false)

    action.leftClick = nil
    action.rightClick = nil
    action.scroll = nil
    action.untoggle = nil
    action.toggle = nil
    action:item(nil)
end

function Paginator:init()
    self.page = action_wheel:createPage()
    self.index = 1
    self.data = {}
    self.slots = {}

    for i = 1, 6 do
        self.slots[i] = self.page:newAction(i):title(i)
    end

    self.back = self.page:newAction(7):title("Back")
    self.forward = self.page:newAction(8):title("Forward")

    function self.back.leftClick()
        self.index = self.index - 1
        self:update()
    end

    function self.forward.leftClick()
        self.index = self.index + 1
        self:update()
    end
end

function Paginator:update()
    for i = 1, 6 do
        local paginatedDataIndex = self.data[i + (self.index - 1) * 6]
        local action = self.slots[i]
        reset(action)

        if paginatedDataIndex == nil then
            paginatedDataIndex = {
                title = "Empty",
                color = vec(0, 0, 0),
                hoverColor = vec(0, 0, 0)
            }
        end

        for name, v in pairs(paginatedDataIndex) do
            if action[name] ~= nil then
                action[name](action, v)
            end
        end
    end

    local back = self.index > 1 and vec(0, 1, 0) or vec(1, 0, 0)
    local forward = self.index < math.ceil(#self.data / 6) and vec(0, 1, 0) or vec(1, 0, 0)

    self.back:color(back)
    self.forward:color(forward)

    self.back:hoverColor(back + vec(0.7, 0.7, 0.7))
    self.forward:hoverColor(forward + vec(0.7, 0.7, 0.7))
end

function Paginator:show(reset)
    action_wheel:setPage(self.page)
    if reset == nil or reset then
        self.index = 1
    end
    self:update()
end

return Paginator