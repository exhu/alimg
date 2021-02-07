module BufImg

struct Img
    w::Int32
    h::Int32
    buf::Array{UInt8}
end

function load(fn::String)::Img
    w = 0
    h = 0
    buf = []
    open(fn) do io
        w = read(io, Int32)
        h = read(io, Int32)
        sz = w*h*4
        buf = Array{UInt8}(undef, sz)
        read!(io, buf)
    end
    Img(w,h,buf)
end

end