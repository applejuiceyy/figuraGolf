local Paginator = require("golf/wheel/paginator")

local state = require("golf/state")


local selectedPole = 0
local polepage = action_wheel:createPage()
local polePaginator = Paginator:new()

polepage:newAction():title("Delete"):item("barrier"):onLeftClick(function()
    state:NETWORK_deletePole(selectedPole)
    polePaginator:show(false)
end)


local function updatePoles()
    polePaginator.data = {}

    polePaginator.data[1] = {
        title = "New Flag",
        color = vec(0.5, 0.3, 0.1),
        onLeftClick = function()
            state:NETWORK_createPole(player:getPos())
        end
    }

    for i, v in pairs(state.poles) do
        table.insert(polePaginator.data, {
            title = "Flag (id: " .. i .. ")",
            color = vec(0, 0, 0.5),
            hoverColor = vec(0, 0, 1),
            onLeftClick = function()
                selectedPole = i
                action_wheel:setPage(polepage)
            end
        })
    end

    polePaginator:update()
end

state.updatePoles:register(updatePoles)
updatePoles()

return polePaginator