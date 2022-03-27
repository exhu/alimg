module PixelDither
export dither_image
using Main.BufImg
using Main.ColorReducer
export PixelDitherObj


struct PixelDitherObj
    function PixelDitherObj()
        new()
    end
end

function dither_image(o::PixelDitherObj, img::Img, cr::ColorReducerObj)
        for y::WidthType = WidthType(0):(img.h-WidthType(1))
            for x::WidthType = WidthType(0):(img.w-WidthType(1))
                dither_pixel(img, cr, x, y)
            end
        end
end

function dither_pixel(img, cr, x, y)
    ofs = BufImg.ofs(img, x, y)
    rgba = get_pixel_at(img, ofs)
    rgbaReduced = reduce_to_closest(cr, rgba)
    set_pixel_at(img, ofs, rgbaReduced)
    rgbaDiff = calc_diff(rgba, rgbaReduced)
    
    # order, apply error to original pixels
    # (x-1,y+1) = 3/16 , (x,y+1) = 5/16, (x+1,y+1) = 1/16, (x+1, y)=7/16
    
    correct_pixel(img, WidthType(x-1), WidthType(y+1), 3, rgbaDiff);
    correct_pixel(img, x, WidthType(y+1), 5, rgbaDiff);
    correct_pixel(img, WidthType(x+1), WidthType(y+1), 1, rgbaDiff);                
    correct_pixel(img, WidthType(x+1), y, 7, rgbaDiff);                                 
end

function correct_pixel(img, x::WidthType, y::WidthType, coef::Int, rgbaDiff)
    if is_in_bounds(img, x,y)
            ofs = BufImg.ofs(img, x,y)
            rgbaTemp = get_pixel_at(img, ofs)
            adjusted = adjust_temp(coef, rgbaTemp, rgbaDiff)
            set_pixel_at(img, ofs, adjusted)
    end
end

function adjust_temp(coef::Int, rgbaTemp::Rgba, rgbaDiff::Rgba)::Rgba
    adjusted = Rgba(
        clamp(rgbaTemp.r + div(rgbaDiff.r * coef, 16)),
        clamp(rgbaTemp.g + div(rgbaDiff.g * coef, 16)),
        clamp(rgbaTemp.b + div(rgbaDiff.b * coef, 16)),
        clamp(rgbaTemp.a + div(rgbaDiff.a * coef, 16)))
end

function clamp(v::Int)::Int
    if v < 0
        return 0
    end
    
    if v > 255
        return 255
    end
    
    v
end

function calc_diff(rgba::Rgba, rgbaReduced::Rgba)::Rgba
    diff = Rgba(rgba.r - rgbaReduced.r,
        rgba.g - rgbaReduced.g,
        rgba.b - rgbaReduced.b,
        rgba.a - rgbaReduced.a)
    diff
end


end