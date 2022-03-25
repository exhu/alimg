module ColorReducer
export ColorReducerObj, reduce_to_closest

using Main.BufImg

struct ColorReducerObj
    lookups::Array{Int32}

    function ColorReducerObj()
        new(init_lookups())
    end
end

function reduce_color(o::ColorReducerObj, v::Int32)
    o.lookups[v+1]
end

function reduce_to_closest(o::ColorReducerObj, rgba::Rgba)::Rgba
    destRgba = Rgba(
        reduce_color(o, rgba.r),
        reduce_color(o, rgba.g),
        reduce_color(o, rgba.b),
        reduce_color(o, rgba.a))
    destRgba
end
    
function downgrade(a::Int32, targetBitCount::Int32)::Int32
    maxv = ((Int32(1) << targetBitCount) - Int32(1))
    # ((a / 255.f) * maxv) / maxv * 255.f
    div(div(a * maxv, Int32(255)) * Int32(255), maxv)
end

function downgrade_component(a::Int32, cNum::Int32)::Int32
    # cNum not used
    downgrade(a, Int32(4))
end

function init_lookups()
    lookups = Base.zeros(Int32, 256)
    for i::Int32 = 0:255
        lookups[i+1] = downgrade_component(i::Int32, Int32(0))
    end
    lookups
end

end