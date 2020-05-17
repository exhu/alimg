pub mod bufimg {
    use std::fs::File;
    use std::io::{Read, Write};
    use std::rc::Rc;
    use std::borrow::Borrow;

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

    type DowngradeFn = dyn Fn(&Rgba) -> Rgba;
    pub enum PixelFormat {
        Pf4444,
        Pf565,
        Pf5551
    }

    pub struct ColorReducer {
        downgrade: Box<DowngradeFn>,
        lookups: Rc<[i32]>,
    }

    fn downgrade(a: i32, bits: i32) -> i32 {
        let maxv = (1 << bits) - 1;
        // ((a / 255.f) * maxv) / maxv * 255.f
        a * maxv / 255 * 255 / maxv
    }

    fn lookup(table: &[i32], v:&Rgba) -> Rgba {
        Rgba::new(table[v.r as usize], table[v.g as usize], table[v.b as usize], table[v.a as usize])
    }

    impl ColorReducer {
        pub fn new(pf: PixelFormat) -> ColorReducer {
            let mut reducer = ColorReducer { downgrade : Box::new(|_a| Rgba::new(0, 0, 0, 0)), lookups: Rc::new([])};
            reducer.init(pf);
            reducer
        }

        fn init(&mut self, pf: PixelFormat) {
            match pf {
                PixelFormat::Pf4444 => {
                    let mut lookups = [0i32; 256];
                    for i in 0..256 {
                        lookups[i] = downgrade(i as i32, 4);
                    }

                    self.lookups = Rc::new(lookups);
                    let lookups = Rc::clone(&self.lookups);

                    self.downgrade = Box::new(move |a| {
                        lookup(lookups.borrow(), a)
                    })
                },
                _ => panic!("not implemented")
            }
        }

        pub fn reduce_to_closest(&self, src: &Rgba) -> Rgba {
            (self.downgrade)(src)
        }
    }

    fn calc_diff(rgba: &Rgba, reduced: &Rgba) -> Rgba {
        Rgba::new(rgba.r - reduced.r, rgba.g - reduced.g, rgba.b - reduced.b, rgba.a - reduced.a)
    }

    fn clamp(i: i32) -> i32 {
        if i < 0 {
            return 0;
        } else if i > 255 {
            return 255;
        }
        i
    }

    fn adjust_comp(c: i32, diff: i32, coef: i32) -> i32 {
        clamp(c + diff * coef / 16)
    }

    fn adjust_rgba(rgba: &Rgba, diff: &Rgba, coef: i32) -> Rgba {
        Rgba::new(adjust_comp(rgba.r, diff.r, coef),
            adjust_comp(rgba.g, diff.g, coef),
            adjust_comp(rgba.b, diff.b, coef),
            adjust_comp(rgba.a, diff.a, coef))
    }

    fn correct_pixel(img: &mut dyn PixelProvider, diff: &Rgba, x: i32, y: i32, coef: i32) {
        if img.is_in_bounds(x, y) {
            let ofs = img.ofs(x, y);
            let mut rgba = img.get_pixel_at(ofs);
            rgba = adjust_rgba(&rgba, &diff, coef);
            img.set_pixel_at(ofs, &rgba);
        }
    }

    pub fn dither_image(img: &mut dyn PixelProvider, reducer: &ColorReducer) {
        let w = img.get_width();
        let h = img.get_height();

        for y in 0..h {
            for x in 0..w {
                let ofs = img.ofs(x, y);
                let rgba = img.get_pixel_at(ofs);
                let rgba_reduced = reducer.reduce_to_closest(&rgba);
                img.set_pixel_at(ofs, &rgba_reduced);
                let diff = calc_diff(&rgba, &rgba_reduced);

                //////////////////////////
                // order, apply error to original pixels
                // (x-1,y+1) = 3/16 , (x,y+1) = 5/16, (x+1,y+1) = 1/16, (x+1, y)=7/16
                
                correct_pixel(img, &diff, x-1, y+1, 3);
                correct_pixel(img, &diff, x, y+1, 5);
                correct_pixel(img, &diff, x+1, y+1, 1);                
                correct_pixel(img, &diff, x+1, y, 7);                                 
            }
        }
    }

    #[cfg(test)]
    pub mod tests {
        use crate::bufimg::*;
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

        #[test]
        fn reduce_color() {
            assert_eq!(255, downgrade(255, 4));
            assert_eq!(0, downgrade(0, 4));
            assert_eq!(119, downgrade(120, 4));

            let reducer = ColorReducer::new(PixelFormat::Pf4444);
            let orig = Rgba::new(230, 120, 127, 255);
            let reduced = reducer.reduce_to_closest(&orig);
            assert_eq!(reduced, Rgba::new(221, 119, 119, 255));
        }
    }
}