pub mod bufimg {
    use std::fs::File;
    use std::io::{Read, Write};

    #[derive(PartialEq, Debug)]
    pub struct Rgba {
        pub r: i32,
        pub g: i32,
        pub b: i32,
        pub a: i32,
    }

    impl Rgba {
        pub fn new(r:i32, g:i32, b:i32, a:i32) -> Rgba {
            Rgba{r,g,b,a}
        }
    }

    pub trait PixelProvider {
        fn is_in_bounds(&self, x: i32, y: i32) -> bool;
        fn get_width(&self) -> i32;
        fn get_height(&self) -> i32;
        fn ofs(&self, x:i32, y:i32) -> i32;
        fn set_pixel_at(&mut self, byteofs: i32, rgba: &Rgba);
        fn get_pixel_at(&self, byteofs: i32) -> Rgba;
    }

    pub struct BufImg {
        width: i32,
        height: i32,
        data: Box<[u8]>
    }

    impl BufImg {
        pub fn alloc(w: i32, h: i32) -> BufImg {
            let data = vec![0; (w*h*4) as usize];
            BufImg { width: w, height: h, data: data.into_boxed_slice() }
        }

        pub fn save(&self, fname: &str) -> std::io::Result<()> {
            let mut f = File::create(fname)?;
            f.write(&self.width.to_le_bytes())?;
            f.write(&self.height.to_le_bytes())?;
            f.write(&self.data)?;
            Ok(())
        }

        pub fn load(fname: &str) -> Result<BufImg, std::io::Error> {
            let mut img = BufImg { width:0, height:0, data: Box::from([]) };
            let mut f = File::open(fname)?;
            let mut read_i32 = [0u8; 4];
            f.read(&mut read_i32)?;
            img.width = i32::from_le_bytes(read_i32);
            if img.width <= 0 {
                panic!("image width <= 0");
            } 
            f.read(&mut read_i32)?;
            img.height = i32::from_le_bytes(read_i32);
            if img.height <= 0 {
                panic!("image width <= 0");
            } 
            img.data = vec![0u8; (img.width*img.height*4) as usize].into_boxed_slice();
            f.read(&mut img.data)?;
            Ok(img)
        }
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


    #[cfg(test)]
    pub mod tests {
        use crate::bufimg::{BufImg, PixelProvider, Rgba};
        use std::env;
        use std::fs;

        #[test]
        fn set_get_pixels() {
            let w = 3;
            let h = 4;
            let mut img = BufImg::alloc(w,h);
            assert_eq!(w, img.get_width());
            assert_eq!(h, img.get_height());
            assert_eq!(img.data.len(), (w*h*4) as usize);

            assert_eq!(img.is_in_bounds(3, 0), false);
            assert_eq!(img.is_in_bounds(0, 4), false);
            assert_eq!(img.is_in_bounds(2, 3), true);
            assert_eq!(img.is_in_bounds(-1, -2), false);
            assert_eq!(img.is_in_bounds(0, 0), true);

            img.set_pixel_at(0, &Rgba {r:1, g:2, b:3, a:4});
            let result_pixel = img.get_pixel_at(0);
            assert_eq!(result_pixel, Rgba {r:1, g:2, b:3, a:4});
            assert_eq!(img.data[3], 4);
            assert_eq!(img.data[4], 0);

            assert_eq!(img.ofs(2, 1), w*1*4 + 2*4);
        }

        #[test]
        fn save_load() -> std::io::Result<()> {
            let mut tempfn = env::temp_dir();
            tempfn.push("temp_img.buf");
            if tempfn.exists() {
                fs::remove_file(tempfn.clone())?;
            }

            let mut orig_img = BufImg::alloc(3, 2);
            let sample_rgba = Rgba::new(1,7,9,12);
            let sample_ofs = orig_img.ofs(1, 1);
            orig_img.set_pixel_at(sample_ofs, &sample_rgba);
            let fname = tempfn.to_str().unwrap();
            orig_img.save(fname)?;

            let read_img = BufImg::load(fname)?;
            let read_sample = read_img.get_pixel_at(sample_ofs);
            assert_eq!(read_sample, sample_rgba);

            Ok(())
        }
    }
}