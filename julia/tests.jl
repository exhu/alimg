include("BufImg.jl")
include("ColorReducer.jl")
include("PixelDither.jl")

using Test
using Main.BufImg
using Main.ColorReducer
using Main.PixelDither

function test_save_load()
    img = Img(Int32(3),Int32(2))
    set_pixel_at(img, ofs(img, Int32(1), Int32(1)), Rgba(1,2,3,4))
    @test length(img.buf) == 3*2*4
    save(img, "temp.buf")
    new_img = load("temp.buf")
    @test get_pixel_at(new_img, ofs(img, Int32(1), Int32(1))) ==
        get_pixel_at(img, ofs(img, Int32(1), Int32(1)))
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
