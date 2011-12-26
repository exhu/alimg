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
begin


end;

begin
  writeln('bufdither_java in.buf out.buf');
  reduce(ParamStr(1), ParamStr(2));

end.

