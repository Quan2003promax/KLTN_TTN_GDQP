program MClientLG;

uses
  System.StartUpCopy,
  FMX.Forms,
  PClientmb in 'PClientmb.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
