program bufdither_fpc;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, bufimg, ditherproc
  { you can add units after this };

{$R *.res}

procedure reduce(src, dst : string);
var
  cr : TColorReducer;
  img : TBufImg;
  dither : TPixelDither;
  i : integer;
begin
  cr := TColorReducer.Create(pf4444);
  img := TBufImg.Create;
  img.load(src);

  dither := TPixelDither.Create;

  for i := 1 to 100 do
      dither.ditherImage(img, cr);

  img.save(dst);
  dither.Free;
  img.Free;
  cr.Free;
end;


begin
  writeln('bufdither_java in.buf out.buf');


  reduce(ParamStr(1), ParamStr(2));
end.

