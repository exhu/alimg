include("BufImg.jl")
include("ColorReducer.jl")
include("PixelDither.jl")

using .BufImg
using .ColorReducer
using .PixelDither

function main()
    if length(ARGS) != 2
        println("usage: bufdither in.buf out.buf")
        exit(1)
    end

    img = load(ARGS[1])
    cr = ColorReducerObj()
    pd = PixelDitherObj()
    for i = 1:3
        @time dither_image(pd, img, cr)
    end
    save(img, ARGS[2])
end

main()