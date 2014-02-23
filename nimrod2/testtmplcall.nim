template callab(a, b : expr) : stmt =
  a(2,3)
  b(3,4)
  
  
proc aaa(a,b:int) =
  echo(a+b)
  
proc bbb(a,b:int) =
  echo(a*b)
  
callab(aaa, bbb)
