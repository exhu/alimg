use std::env;
use bufdither_rust::bufimg::*;

fn main() {
    println!("Hello, world!");

    let args: Vec<String> = env::args().collect();

    let srcfn = &args[1];
    let dstfn = &args[2];

    println!("src = {}, dst = {}", srcfn, dstfn);

    let mut img = BufImg::load(srcfn).unwrap();
    let reducer = ColorReducer::new(PixelFormat::Pf4444);
    //for _i in 0..100 {
        dither_image(&mut img, &reducer);
    //}
    img.save(dstfn).unwrap();
}
