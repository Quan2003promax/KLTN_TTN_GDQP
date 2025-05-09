program PServerKL2021;

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  UServer in 'UServer.pas' {Form1},
  ServerMethodsKL2021 in 'ServerMethodsKL2021.pas' {ServerMethods1: TDSServerModule},
  ServerContainerKL2021 in 'ServerContainerKL2021.pas' {ServerContainer1: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TServerContainer1, ServerContainer1);
  Application.Run;
end.

