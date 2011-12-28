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
      procedure adjustTemp(coef : integer);inline;
      procedure correctPixel(x, y, coef : integer);
  end;

implementation
var
  down4lookup : array[0..255] of integer;

// most of the time spent in this function (by profiler)
function downgrade(a, targetBitCount : integer) : integer;inline;
var
  maxv : integer;
begin
  maxv := ((1 shl targetBitCount) - 1);
  result := (((a * maxv) div 255) * 255) div maxv;
end;

function downgrade4(a : integer) : integer;inline;
begin
  result := a * 15 div 255 * 17;
end;

function downgrade4444(a, cNum : integer) : integer;
begin
  //result := downgrade(a, 4);
  //result := downgrade4(a);
  result := down4lookup[a];
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
  notLastRow, notLastCol : boolean;
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

            notLastRow := (y < lastRow);
            notLastCol := (x < lastCol);
            if notLastRow then
               begin
                    if x > 0 then
                       correctPixel(x-1, y+1, 3);

                    correctPixel(x, y+1, 5);

                    if notLastCol then
                       correctPixel(x+1, y+1, 1);
               end;

            if notLastCol then
               correctPixel(x+1, y, 7);
          end;


  self.img := nil;
end;

function clamp(v : integer) : integer;inline;
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

// secon most time consuming function according to the profile data
procedure TPixelDither.adjustTemp(coef: integer);inline;
var
  i : integer;
begin
  for i := 0 to 3 do
      begin
        rgbaTemp[i] := clamp(rgbaTemp[i] + rgbaDiff[i] * coef div 16);
      end;
end;

procedure TPixelDither.correctPixel(x, y, coef: integer);
var
  ofs : longint;
begin
  //if img.isInBounds(x, y) then
  //   begin
       ofs := img.getOfs(x, y);
       img.getPixelAt(ofs, rgbaTemp);
       adjustTemp(coef);
       img.setPixelAt(ofs, rgbaTemp);
   //  end;

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


procedure initlookup4;
var
  i : integer;
begin
  for i := 0 to 255 do
      down4lookup[i] := downgrade4(i);
end;

initialization

initlookup4;

end.

