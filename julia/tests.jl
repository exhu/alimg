include("BufImg.jl")
include("ColorReducer.jl")
include("PixelDither.jl")

using Test
using Main.BufImg
using Main.ColorReducer
using Main.PixelDither

function test_save_load()
    orig = Img(Int32(3),Int32(2))
    @test length(orig.buf) == 3*2*4
    true
end

function test_color_reducer()
    cr = ColorReducerObj()
    @test length(cr.lookups) == 256
    true
end

function test_pixel_dither()
    cr = ColorReducerObj()
    img = Img(Int32(3), Int32(2))
    pd = PixelDitherObj()
    dither_image(pd, img, cr)
    true
end

@test test_save_load() == true
@test test_color_reducer()
@test test_pixel_dither()
