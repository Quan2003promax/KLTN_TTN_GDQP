program PClientLG;

uses
  Vcl.Forms,
  ui_login in 'ui_login.pas' {TformLG};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTformLG, TformLG);
  Application.Run;
end.
