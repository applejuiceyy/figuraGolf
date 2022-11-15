local ballPaginator = require("golf/wheel/balls")
local flagsPaginator = require("golf/wheel/flags")
local state = require("golf/state")

local page = action_wheel:createPage()

page:newAction():title("Balls"):item("white_wool"):onLeftClick(function() ballPaginator:show() end)
page:newAction():title("Poles"):item("oak_fence"):onLeftClick(function() flagsPaginator:show() end)
page:newAction():title("Unfocus Balls"):item("red_wool"):onLeftClick(function() state:unfocusBall() end)

action_wheel:setPage(page)


action_wheel.rightClick = function() action_wheel:setPage(page) end
