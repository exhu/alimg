ffi = require 'ffi'
bit = require 'bit'

-----

local M = {}

local ColorReducer = {}
M.ColorReducer = ColorReducer

local downgrade4lookup = ffi.new("int32_t[?]", 256)

local function downgrade4444(a, cNum)
    return downgrade4lookup[a]
end

local function downgrade(a, targetBitCount)
    local maxv = bit.lshift(1, targetBitCount) - 1;
    return a * maxv / 255 * 255 / maxv
end

local function initLookups()
    for i = 0, 255 do
        downgrade4lookup[i] = downgrade(i, 4)
    end
end



function ColorReducer.create()
    initLookups()
    local inst = {}
    setmetatable(inst, {__index = ColorReducer})
    inst.downgr = downgrade4444
    return inst    
end


function ColorReducer:reduceToClosest(rgba, destRGBA)
    for i = 0,3 do
        destRGBA[i] = self.downgr(rgba[i], i)
    end
end


------
return M
