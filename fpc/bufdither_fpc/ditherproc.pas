unit ditherproc;

{$mode objfpc}{$H+}

interface

uses
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

implementation

function downgrade(a, targetBitCount : integer) : integer;
var
  maxv : integer;
begin
  maxv := ((1 shl targetBitCount) - 1);
  result := a * maxv div 255 * 25 div maxv;
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

