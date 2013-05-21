-- pixel interface, not used as now
PixelProvider = {
    
}

boolean isInBounds(int x, int y);
    
    int getWidth();
    int getHeight();
    /// returns false if x,y is out of bounds
    int ofs(int x, int y);   
    void setPixelAt(int byteofs, int rgba[]);
    void getPixelAt(int byteofs, int rgba[]);

function PixelProvider:w()
end

function PixelProvider:h()
end

function PixelProvider:ofs(x,y)
    return 0
end

function PixelProvider:setPixelAt(byteofs, rgba)
end

function PixelProvider:getPixelAt(byteofs, rgba)
end


