unit Website1;

interface

uses System.SysUtils, System.Classes, Web.HTTPApp, Data.DBXDataSnap,
  Data.DBXCommon, IPPeerClient, Data.FMTBcd, Data.SqlExpr, Data.DB,
  Datasnap.DBClient, Datasnap.DSConnect, Data.DBXMSSQL;

type
  TWebModule1 = class(TWebModule)
    SQLConnection1: TSQLConnection;
    DSProviderConnection1: TDSProviderConnection;
    ClientDataSet1: TClientDataSet;
    DataSource1: TDataSource;
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TWebModule1;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  HTML: string;
begin
  HTML :=
    '<!DOCTYPE html>' +
    '<html lang="vi">' +
    '<head>' +
    '  <meta charset="UTF-8">' +
    '  <meta name="viewport" content="width=device-width, initial-scale=1.0">' +
    '  <title>TTN - Tra cứu GDQP</title>' +
    '  <style>' +
    '    body { margin: 0; padding: 0; font-family: Segoe UI, sans-serif;' +
    '           background: linear-gradient(to right, #e0f7ff, #ffe0f7); }' +
    '    .container { display: flex; justify-content: center; align-items: center;' +
    '                 height: 100vh; }' +
    '    .box { background: #ffffff; padding: 40px; border-radius: 20px; width: 500px;' +
    '           box-shadow: 0 4px 20px rgba(0,0,0,0.1); text-align: center; }' +
    '    img.logo { width: 180px; margin-bottom: 20px; border-radius: 12px; }' +
    '    h1 { font-size: 28px; margin-bottom: 10px; }' +
    '    p { color: #666; font-size: 14px; margin-bottom: 20px; }' +
    '    .btn { display: inline-block; margin: 10px; padding: 12px 20px; font-weight: bold;' +
    '           background: #f5f5f5; text-decoration: none; color: #333; border-radius: 8px;' +
    '           transition: 0.3s ease; box-shadow: 1px 1px 6px rgba(0,0,0,0.1); }' +
    '    .btn:hover { background: #d0eaff; transform: translateY(-2px); }' +
    '    footer { margin-top: 30px; font-size: 12px; color: #888; }' +
    '  </style>' +
    '</head>' +
    '<body>' +
    '  <div class="container">' +
    '    <div class="box">' +
    '      <img class="logo" src="/logotruong.png" alt="logo">' +
    '      <h1>👋 Hi, Welcome back!</h1>' +
    '      <p>Ứng dụng Web dành cho sinh viên trường Đại học Tây Nguyên</p>' +
    '      <div>' +
    '        <a class="btn" href="/ketqua?masv=21103083">🎓 Kết quả</a>' +
    '        <a class="btn" href="#">📅 Lịch học</a>' +
    '        <a class="btn" href="#">🧰 Công cụ</a>' +
    '      </div>' +
    '      <footer>🌀 WebBroker Delphi • Made by <b>AnhQuan</b></footer>' +
    '    </div>' +
    '  </div>' +
    '</body>' +
    '</html>';

  Response.Content := HTML;
  Handled := True;
end;

end.
