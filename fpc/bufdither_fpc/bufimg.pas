unit bufimg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TIntRGBA = array[0..3] of integer;

  // originally from PixelProvider interface in java
  TBufImgBase = class
    public
      function isInBounds(x, y : integer) : boolean;virtual;abstract;
      function getOfs(x, y : integer) : longint;virtual;abstract;
      procedure getPixelAt(byteofs : integer; out rgba : TIntRGBA);virtual;abstract;
      procedure setPixelAt(byteofs : integer; var rgba : TIntRGBA);virtual;abstract;

      function getWidth : integer;virtual;abstract;
      function getHeight : integer;virtual;abstract;
  end;


  { TBufImg }

  TBufImg = class(TBufImgBase)
    public
      constructor Create;
      destructor Destroy; override;

      procedure load(fn : string);
      procedure save(fn : string);

      function isInBounds(x, y : integer) : boolean;override;
      function getOfs(x, y : integer) : longint;override;
      procedure getPixelAt(byteofs : integer; out rgba : TIntRGBA);override;
      procedure setPixelAt(byteofs : integer; var rgba : TIntRGBA);override;

      function getWidth : integer;override;
      function getHeight : integer;override;

    private
      fwidth : integer;
      fheight : integer;
      buf : pbyte;

      function sz : longint;
  end;

implementation

{ TBufImg }

constructor TBufImg.Create;
begin
  inherited Create;

  fwidth := 0;
  fheight := 0;
  buf := nil;
end;

destructor TBufImg.Destroy;
begin
  Freemem(buf);

  inherited Destroy;
end;

procedure TBufImg.load(fn: string);
var
  f: file;
  bufsz : longint;
begin
  assignFile(f, fn);
  reset(f, 1);
  BlockRead(f, fwidth, 4);
  BlockRead(f, fheight, 4);

  //writeln('image ', fn, ' wh = ', fwidth, ', ', fheight);

  Freemem(buf);

  bufsz := sz;
  buf := GetMem(bufsz);

  //writeln('allocated ', bufsz);

  BlockRead(f, buf^, bufsz);

  //writeln('read image.');

  closeFile(f);
end;

procedure TBufImg.save(fn: string);
var
  f: file;

begin
  assignFile(f, fn);
  rewrite(f, 1);
  BlockWrite(f, fwidth, 4);
  BlockWrite(f, fheight, 4);

  BlockWrite(f, buf^, sz);

  closeFile(f);
end;

function TBufImg.isInBounds(x, y: integer): boolean;
begin
  Result:= (x > 0) and (x < fwidth) and (y > 0) and (y < fheight);
end;

function TBufImg.getOfs(x, y: integer): longint;
begin
  Result:= (y * fwidth + x)*4;//y * fwidth * 4 + x*4;
end;

procedure TBufImg.getPixelAt(byteofs: integer; out rgba: TIntRGBA);
var i : longint;
begin
  for i := 0 to 3 do
    begin
      rgba[i] := buf[byteofs];
      inc(byteofs);
    end;
end;

procedure TBufImg.setPixelAt(byteofs: integer; var rgba: TIntRGBA);
var i : longint;
begin
  for i := 0 to 3 do
    begin
      buf[byteofs] := rgba[i];
      inc(byteofs);
    end;
end;

function TBufImg.getWidth: integer;
begin
  Result:=fwidth
end;

function TBufImg.getHeight: integer;
begin
  Result:=fheight;
end;

function TBufImg.sz: longint;
begin
  result := fwidth * fheight * 4;
end;

end.

