module BufImg

export Img, load, save, ofs, Rgba, set_pixel_at, get_pixel_at, sz, is_in_bounds

struct Img
    w::Int32
    h::Int32
    buf::Array{UInt8}

    function Img(w::Int32, h::Int32) 
        new(w, h, Base.zeros(UInt8, sz(w,h)))
    end

    function Img(w::Int32, h::Int32, buf) 
        new(w, h, buf)
    end
end

struct Rgba
    r::Int32
    g::Int32
    b::Int32
    a::Int32
end

function load(fn::String)::Img
    w::Int32 = 0
    h::Int32 = 0
    buf::Array{UInt8} = []
    open(fn) do io
        w = read(io, Int32)
        h = read(io, Int32)
        bufsz = sz(w,h)
        buf = Array{UInt8}(undef, bufsz)
        read!(io, buf)
    end
    Img(w,h,buf)
end

function save(img:: Img, fn::String)
    open(fn, "w") do io
        write(io, img.w)
        write(io, img.h)
        write(io, img.buf)
    end
end


function sz(w, h)::Int
    w*h*4
end

function sz(img::Img)::Int
    sz(img.w, img.h)
end

function ofs(img::Img, x::Int32, y::Int32)::Int
    1+(y*img.w + x)*4
end

function set_pixel_at(img::Img, byte_ofs::Int, color::Rgba)
    img.buf[byte_ofs] = convert(UInt8, color.r)
    img.buf[byte_ofs+1] = convert(UInt8, color.g)
    img.buf[byte_ofs+2] = convert(UInt8, color.b)
    img.buf[byte_ofs+3] = convert(UInt8, color.a)
end

function get_pixel_at(img::Img, byte_ofs::Int)::Rgba
    Rgba(img.buf[byte_ofs], img.buf[byte_ofs+1],img.buf[byte_ofs+2],img.buf[byte_ofs+3])
end

function is_in_bounds(img::Img, x::Int32, y::Int32)::Bool
    x >= 0 && y >= 0 && x < img.w && y < img.h
end


end