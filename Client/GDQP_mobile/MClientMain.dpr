program MClientMain;

uses
  System.StartUpCopy,
  FMX.Forms,
  MbClient in 'MbClient.pas' {Form1},
  PClientmb in 'PClientmb.pas' {FormLGMB};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormLGMB, FormLGMB);
  Application.Run;
end.
