-- Author: Applejuice

local class = require("golf/class")

local c
local keybinds = {}
local Keybind = class("Keybind")

function Keybind:init(kb)
    self._kb = kb
    self._presses = 0

    kb.onPress = function()
        self._presses = self._presses + 1
        return c.overriding
    end

    table.insert(keybinds, self)
end

function Keybind:isPressed()
    return self._kb:isPressed()
end

function Keybind:wasPressed()
    if self._presses > 0 then
        self._presses = self._presses - 1
        return true
    end
    return false
end

function Keybind:reset()
    self._presses = 0
end



c = {
    A = Keybind:new(keybind:create("A", "key.keyboard.a")),
    W = Keybind:new(keybind:create("W", "key.keyboard.w")),
    S = Keybind:new(keybind:create("S", "key.keyboard.s")),
    D = Keybind:new(keybind:create("D", "key.keyboard.d")),
    Space = Keybind:new(keybind:create("Space", "key.keyboard.space")),
    Ctrl = Keybind:new(keybind:create("Ctrl", "key.keyboard.left.control")),
    Shift = Keybind:new(keybind:create("Shift", "key.keyboard.left.shift")),
    F5 = Keybind:new(keybind:create("F5", "key.keyboard.f5")),

    unpressAll = function ()
        for _, v in ipairs(keybinds) do v:reset() end
    end,

    overriding = false
}

return c