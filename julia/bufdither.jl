include("BufImg.jl")
include("ColorReducer.jl")
include("PixelDither.jl")

using Main.BufImg
using Main.ColorReducer
using Main.PixelDither

function main()
    if length(ARGS) != 2
        println("usage: bufdither in.buf out.buf")
        exit(1)
    end

    img = load(ARGS[1])
    cr = ColorReducerObj()
    pd = PixelDitherObj()
    dither_image(pd, img, cr)
    save(img, ARGS[2])
end

main()