-- Author: Applejuice (carried over from FiguraTanks project)

function collidesWithRectangle(pos, that)
    --[[particles:newParticle("minecraft:dust 1 1 1 1", that.xyz)
    particles:newParticle("minecraft:dust 1 1 1 1", that.wyz)
    particles:newParticle("minecraft:dust 1 1 1 1", that.xtz)
    particles:newParticle("minecraft:dust 1 1 1 1", that.wtz)
    particles:newParticle("minecraft:dust 1 1 1 1", that.xyh)
    particles:newParticle("minecraft:dust 1 1 1 1", that.wyh)
    particles:newParticle("minecraft:dust 1 1 1 1", that.xth)
    particles:newParticle("minecraft:dust 1 1 1 1", that.wth)
]]

    return pos.w > that.x and pos.t > that.y and pos.h > that.z
    and pos.x < that.w and pos.y < that.t and pos.z < that.h
end

function collidesWithBlock (block, pos)
    if block:hasCollision() then
        for _, collider in pairs(block:getCollisionShape()) do
            local blockpos = block:getPos()

            local colliding = collidesWithRectangle(pos, blockpos.xyzxyz + collider)


            if colliding then
                return collider
            end
        end
    end

    return false
end

return {
    collidesWithBlock = collidesWithBlock,

    collidesWithRectangle = collidesWithRectangle,
    collidesWithWorld = function (shape, margin)
        if margin == nil then
            margin = vec(0, -0.5, 0, 0, 0, 0)
        end
        local withmargin = shape + margin
        for x = math.floor(withmargin.x), math.floor(withmargin.w) do
            for y = math.floor(withmargin.y), math.floor(withmargin.t) do
                for z = math.floor(withmargin.z), math.floor(withmargin.h) do
                    local block = world.getBlockState(x, y, z)
                    local collider = collidesWithBlock(block, shape)

                    if collider then
                        return block, collider
                    end
                end
            end
        end
        return false
    end
} 