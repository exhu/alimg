pub mod bufimg {

struct Rgba {
    pub r: i32,
    pub g: i32,
    pub b: i32,
    pub a: i32,
}

trait PixelProvider {
    fn is_in_bounds(&self, x: i32, y: i32) -> bool;
    fn get_width(&self) -> i32;
    fn get_height(&self) -> i32;
    fn ofs(&self, x:i32, y:i32) -> i32;
    fn set_pixel_at(&mut self, byteofs: i32, rgba: &Rgba);
    fn get_pixel_at(&self, byteofs: i32) -> Rgba;
}


struct BufImg {
    width: i32,
    height: i32,
    data: Box<[u8]>
}

impl PixelProvider for BufImg {
    fn is_in_bounds(&self, x:i32, y: i32) -> bool {
        (x >= 0 && x < self.width) && (y >= 0 && y < self.height)
    }

    fn get_width(&self) -> i32 {
        self.width
    }

    fn get_height(&self) -> i32 {
        self.height
    }

    fn ofs(&self, x:i32, y:i32) -> i32 {
        y*self.width*4 + x*4
    }

    fn set_pixel_at(&mut self, byteofs: i32, rgba: &Rgba) {
        let ofs = byteofs as usize;
        self.data[ofs] = rgba.r as u8;
        self.data[ofs+1] = rgba.g as u8;
        self.data[ofs+2] = rgba.b as u8;
        self.data[ofs+3] = rgba.a as u8;
    }

    fn get_pixel_at(&self, byteofs: i32) -> Rgba {
        let ofs = byteofs as usize;
        Rgba { r : self.data[ofs] as i32,
            g : self.data[ofs+1] as i32,
            b : self.data[ofs+2] as i32,
            a : self.data[ofs+3] as i32 }
    }
}
    

}