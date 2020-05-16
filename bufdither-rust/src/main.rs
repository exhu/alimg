use std::env;

fn main() {
    println!("Hello, world!");

    let args: Vec<String> = env::args().collect();

    let srcfn = &args[1];
    let dstfn = &args[2];

    println!("src = {}, dst = {}", srcfn, dstfn);
}
