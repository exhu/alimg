unit ditherproc;

{$mode objfpc}{$H+}

interface

uses
  sysutils,
  bufimg;

type
  TPixelFormat = (pf4444, pf565, pf5551);

  TDowngradeProc = function(a, cNum : integer) : integer;

  { TColorReducer }

  TColorReducer = class
    public
      constructor Create(pf : TPixelFormat);
      procedure reduceToClosest(var rgba : TIntRGBA; var destRGBA : TIntRGBA);

    private
      downgr : TDowngradeProc;
  end;


  { TPixelDither }

  TPixelDither = class
    public
      constructor Create;
      destructor Destroy; override;

      procedure ditherImage(img : TBufImgBase; cr : TColorReducer);

    private
      rgbaDiff, rgbaTemp : TIntRGBA;
      img : TBufImgBase;

      procedure calcDiff(var rgba : TIntRGBA; var rgbaReduced : TIntRGBA);
      procedure adjustTemp(coef : integer);
      procedure correctPixel(x, y, coef : integer);
  end;

implementation

function downgrade(a, targetBitCount : integer) : integer;
var
  maxv : integer;
begin
  maxv := ((1 shl targetBitCount) - 1);
  result := (((a * maxv) div 255) * 255) div maxv;
end;

function downgrade4444(a, cNum : integer) : integer;
begin
  result := downgrade(a, 4);
end;

function downgrade565(a, cNum : integer) : integer;
begin
  if cNum = 1 then
     exit(downgrade(a, 6));

  result := downgrade(a, 5);
end;

function downgrade5551(a, cNum : integer) : integer;
begin
  if cNum = 3 then
     exit(downgrade(a, 1));

  result := downgrade(a, 5);
end;

{ TPixelDither }

constructor TPixelDither.Create;
begin
  inherited;

  img := nil;
end;

destructor TPixelDither.Destroy;
begin
  img := nil;

  inherited Destroy;
end;

procedure TPixelDither.ditherImage(img: TBufImgBase; cr: TColorReducer);
var
  lastCol, lastRow : integer;
  ofs : longint;
  rgba, rgbaReduced : TIntRGBA;
  x, y : integer;
begin
  self.img := img;

  lastCol := img.getWidth-1;
  lastRow := img.getHeight-1;

  for y := 0 to lastRow do
      for x := 0 to lastCol do
          begin
            ofs := img.getOfs(x, y);
            img.getPixelAt(ofs, rgba);
            cr.reduceToClosest(rgba, rgbaReduced);
            img.setPixelAt(ofs, rgbaReduced);

            calcDiff(rgba, rgbaReduced);

            //////////////////////////
            // order, apply error to original pixels
            // (x-1,y+1) = 3/16 , (x,y+1) = 5/16, (x+1,y+1) = 1/16, (x+1, y)=7/16


            correctPixel(x-1, y+1, 3);
            correctPixel(x, y+1, 5);
            correctPixel(x+1, y+1, 1);
            correctPixel(x+1, y, 7);
          end;


  self.img := nil;
end;

function clamp(v : integer) : integer;
begin
  if v < 0 then
     exit(0);

  if v > 255 then
     exit(255);

  result := v;
end;

procedure TPixelDither.calcDiff(var rgba: TIntRGBA; var rgbaReduced: TIntRGBA);
var
  i : integer;
begin
  for i := 0 to 3 do
      rgbaDiff[i] := rgba[i] - rgbaReduced[i];
end;

procedure TPixelDither.adjustTemp(coef: integer);
var
  i : integer;
begin
  for i := 0 to 3 do
      begin
        rgbaTemp[i] := rgbaTemp[i] + rgbaDiff[i] * coef div 16;
        rgbaTemp[i] := clamp(rgbaTemp[i]);
      end;
end;

procedure TPixelDither.correctPixel(x, y, coef: integer);
var
  ofs : longint;
begin
  if img.isInBounds(x, y) then
     begin
       ofs := img.getOfs(x, y);
       img.getPixelAt(ofs, rgbaTemp);
       adjustTemp(coef);
       img.setPixelAt(ofs, rgbaTemp);
     end;

end;


{ TColorReducer }

constructor TColorReducer.Create(pf: TPixelFormat);
begin
  inherited Create;
  downgr := nil;

  case pf of
  pf4444 : downgr := @downgrade4444;
  pf565 : downgr := @downgrade565;
  pf5551 : downgr := @downgrade5551;
  end;
end;

procedure TColorReducer.reduceToClosest(var rgba: TIntRGBA;
  var destRGBA: TIntRGBA);
var
  i : integer;
begin
  for i := 0 to 3 do
      destRGBA[i] := downgr(rgba[i], i);
end;


end.

