local Paginator = require("golf/wheel/paginator")

local state = require("golf/state")


local selectedBall = 0
local ballpage = action_wheel:createPage()
local ballPaginator = Paginator:new()

ballpage:newAction():title("Focus"):item("arrow"):onLeftClick(function() state:focusBall(selectedBall) end)
ballpage:newAction():title("Delete"):item("barrier"):onLeftClick(function()
    state:NETWORK_deleteBall(selectedBall)
end)











local function updateBalls()
    ballPaginator.data = {}

    ballPaginator.data[1] = {
        title = "New Ball",
        color = vec(0.5, 0.3, 0.1),
        onLeftClick = function()
            state:NETWORK_createBall(player:getPos() + vec(0, 0.5, 0))
        end
    }

    for i, v in pairs(state.balls) do
        table.insert(ballPaginator.data, {
            title = "Ball (id: " .. i .. ")",
            color = vec(0, 0, 0.5),
            hoverColor = vec(0, 0, 1),
            item = "minecraft:white_wool",
            onLeftClick = function()
                selectedBall = i
                action_wheel:setPage(ballpage)
            end
        })
    end

    if state.balls[selectedBall] == nil then
        selectedBall = 0
        if action_wheel:getCurrentPage() == ballpage then
            ballPaginator:show(false)
        end
    end

    ballPaginator:update()
end

state.updateBalls:register(updateBalls)
updateBalls()

return ballPaginator