-- Author: Applejuice

local class = require("golf/class")

local c
local keys = {}
local Keybind = class("Keybind")

function Keybind:init(kb)
    self._kb = kb
    self._presses = 0

    kb.onPress = function()
        self._presses = self._presses + 1
        return c.overriding
    end

    table.insert(keys, self)
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
    A = Keybind:new(keybinds:newKeybind("A", "key.keyboard.a")),
    W = Keybind:new(keybinds:newKeybind("W", "key.keyboard.w")),
    S = Keybind:new(keybinds:newKeybind("S", "key.keyboard.s")),
    D = Keybind:new(keybinds:newKeybind("D", "key.keyboard.d")),
    Space = Keybind:new(keybinds:newKeybind("Space", "key.keyboard.space")),
    Ctrl = Keybind:new(keybinds:newKeybind("Ctrl", "key.keyboard.left.control")),
    Shift = Keybind:new(keybinds:newKeybind("Shift", "key.keyboard.left.shift")),
    F5 = Keybind:new(keybinds:newKeybind("F5", "key.keyboard.f5")),

    unpressAll = function ()
        for _, v in ipairs(keys) do v:reset() end
    end,

    overriding = false
}

return c