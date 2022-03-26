module ColorReducer
export ColorReducerObj, reduce_to_closest

using Main.BufImg

struct ColorReducerObj
    lookups::Array{ChannelType}

    function ColorReducerObj()
        new(init_lookups())
    end
end

function reduce_color(o::ColorReducerObj, v::ChannelType)
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
    
function downgrade(a::ChannelType, targetBitCount::ChannelType)::ChannelType
    maxv = ((ChannelType(1) << targetBitCount) - ChannelType(1))
    # ((a / 255.f) * maxv) / maxv * 255.f
    div(div(a * maxv, ChannelType(255)) * ChannelType(255), maxv)
end

function downgrade_component(a::ChannelType, cNum::ChannelType)::ChannelType
    # cNum not used
    downgrade(a, ChannelType(4))
end

function init_lookups()
    lookups = Base.zeros(ChannelType, 256)
    for i::ChannelType = 0:255
        lookups[i+1] = downgrade_component(i::ChannelType, ChannelType(0))
    end
    lookups
end

end