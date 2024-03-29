include("BufImg.jl")
include("ColorReducer.jl")
include("PixelDither.jl")

using Test
using Main.BufImg
using Main.ColorReducer
using Main.PixelDither

#using InteractiveUtils

function test_save_load()
    img = Img(WidthType(3), WidthType(2))
    set_pixel_at(img, ofs(img, WidthType(1), WidthType(1)), Rgba(1,2,3,4))
    @test length(img.buf) == 3*2*4
    save(img, "temp.buf")
    new_img = load("temp.buf")
    @test get_pixel_at(new_img, ofs(img, WidthType(1), WidthType(1))) ==
        get_pixel_at(img, ofs(img, WidthType(1), WidthType(1)))

    get_pixel_at(img, ofs(img, WidthType(1), WidthType(1)))
    true
end

function test_color_reducer()
    cr = ColorReducerObj()
    @test length(cr.lookups) == 256
    true
end

function test_pixel_dither()
    cr = ColorReducerObj()
    img = Img(WidthType(16), WidthType(16))
    pd = PixelDitherObj()
    dither_image(pd, img, cr)
    true
end

function test_ofs()
    img = Img(WidthType(640), WidthType(480))
    @test length(img.buf) == (640*480*4)
    @test sz(img) == (640*480*4)
    @test ofs(img, 3, 1) == (640*4 + 3*4 +1)
    @test ofs(img, 639, 479) == (640*4*479 + 639*4 +1)
    true
end

function test_array(buf)
    for i = 1:length(buf)
        buf[i] = (i*3) & 0xFF
    end
end

@test test_save_load() == true
@test test_color_reducer()
@test test_pixel_dither()
@test test_ofs()

@time test_pixel_dither()
@time test_pixel_dither()

buf = zeros(UInt8, 640*480*4)
@time test_array(buf)
@time test_array(buf)